`timescale 1ns/1ps

module tb_IFID;
  // Parámetro de periodo de reloj
  localparam CLK_PERIOD = 10;

  // Señales de estímulo (registros) con sufijo _r
  reg         clk_r;
  reg         i_reset_r;
  reg         i_halt_r;
  reg         i_stall_r;
  reg  [31:0] i_instruction_r;

  // Salida del DUT (wire) con sufijo _w
  wire [31:0] o_instruction_w;

  // Instanciación del DUT
  IFID uut (
    .clk           (clk_r),
    .i_reset       (i_reset_r),
    .i_halt        (i_halt_r),
    .i_stall       (i_stall_r),
    .i_instruction (i_instruction_r),
    .o_instruction (o_instruction_w)
  );

  // Generador de reloj: 10 ns de periodo
  initial begin
    clk_r = 0;
    forever #(CLK_PERIOD/2) clk_r = ~clk_r;
  end

  initial begin
    // --------------------------------------------------------------------
    // 1) RESET inicial activo (reset síncrono en posedge)
    // --------------------------------------------------------------------
    i_reset_r       = 0;
    i_halt_r        = 0;
    i_stall_r       = 0;
    i_instruction_r = 32'hDEAD_BEEF;
    @(posedge clk_r);
    if (o_instruction_w !== 32'h0000_0000)
      $error("RESET inicial falló: o_instruction_w = 0x%08h, esperado 0x00000000", o_instruction_w);
    else
      $display("OK RESET inicial: o_instruction_w = 0x%08h", o_instruction_w);

    // --------------------------------------------------------------------
    // 2) Suelto reset y pruebo escritura normal
    // --------------------------------------------------------------------
    i_reset_r = 1;
    i_instruction_r = 32'hCAFEBABE;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hCAFEBABE)
      $error("WRITE normal falló: o_instruction_w = 0x%08h, esperado 0xCAFEBABE", o_instruction_w);
    else
      $display("OK WRITE normal: o_instruction_w = 0x%08h", o_instruction_w);

    // Otro ciclo normal
    i_instruction_r = 32'h12345678;
    @(posedge clk_r);
    if (o_instruction_w !== 32'h12345678)
      $error("WRITE normal 2 falló: o_instruction_w = 0x%08h, esperado 0x12345678", o_instruction_w);
    else
      $display("OK WRITE normal 2: o_instruction_w = 0x%08h", o_instruction_w);

    // --------------------------------------------------------------------
    // 3) HALT: debe ignorar cambios en i_instruction
    // --------------------------------------------------------------------
    i_halt_r = 1;
    i_instruction_r = 32'hAAAAAAAA;
    @(posedge clk_r);
    if (o_instruction_w !== 32'h12345678)
      $error("HALT falló: o_instruction_w = 0x%08h, esperado 0x12345678", o_instruction_w);
    else
      $display("OK HALT: o_instruction_w permanece = 0x%08h", o_instruction_w);

    // Libero halt y pruebo que retome
    i_halt_r = 0;
    i_instruction_r = 32'hBBBBBBBB;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hBBBBBBBB)
      $error("Post-HALT falló: o_instruction_w = 0x%08h, esperado 0xBBBBBBBB", o_instruction_w);
    else
      $display("OK Post-HALT: o_instruction_w = 0x%08h", o_instruction_w);

    // --------------------------------------------------------------------
    // 4) STALL: al igual que halt, debe ignorar cambios
    // --------------------------------------------------------------------
    i_stall_r = 1;
    i_instruction_r = 32'hCCCCCCCC;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hBBBBBBBB)
      $error("STALL falló: o_instruction_w = 0x%08h, esperado 0xBBBBBBBB", o_instruction_w);
    else
      $display("OK STALL: o_instruction_w permanece = 0x%08h", o_instruction_w);

    // Libero stall y pruebo que retome
    i_stall_r = 0;
    i_instruction_r = 32'hDDDDDDDD;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hDDDDDDDD)
      $error("Post-STALL falló: o_instruction_w = 0x%08h, esperado 0xDDDDDDDD", o_instruction_w);
    else
      $display("OK Post-STALL: o_instruction_w = 0x%08h", o_instruction_w);

    // --------------------------------------------------------------------
    // 5) RESET en medio de la operación
    // --------------------------------------------------------------------
    // Cambio instrucción, luego fuerzo reset
    i_instruction_r = 32'hEEEEEEEE;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hEEEEEEEE)
      $error("Pre-RESET medio falló: o_instruction_w = 0x%08h, esperado 0xEEEEEEEE", o_instruction_w);
    else
      $display("OK Pre-RESET medio: o_instruction_w = 0x%08h", o_instruction_w);

    // Fuerzo reset
    i_reset_r = 0;
    @(posedge clk_r);
    if (o_instruction_w !== 32'h0000_0000)
      $error("RESET medio falló: o_instruction_w = 0x%08h, esperado 0x00000000", o_instruction_w);
    else
      $display("OK RESET medio: o_instruction_w = 0x%08h", o_instruction_w);

    // Libero reset y pruebo una última vez
    i_reset_r = 1;
    i_instruction_r = 32'hFFFFFFFF;
    @(posedge clk_r);
    if (o_instruction_w !== 32'hFFFFFFFF)
      $error("Post-RESET final falló: o_instruction_w = 0x%08h, esperado 0xFFFFFFFF", o_instruction_w);
    else
      $display("OK Post-RESET final: o_instruction_w = 0x%08h", o_instruction_w);

    $display("=== Todos los tests de IFID pasaron exitosamente ===");
    #CLK_PERIOD;
    $finish;
  end

endmodule
