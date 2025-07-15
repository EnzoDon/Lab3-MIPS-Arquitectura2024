`timescale 1ns/1ps

module tb_PC;
  // Parámetros
  localparam CLK_PERIOD = 10;

  // Señales de estímulo
  reg         clk_r;
  reg         i_reset_r;
  reg  [31:0] i_jump_address_r;
  reg         i_jump_r;
  reg         i_halt_r;
  reg         i_stall_r;

  // Salida
  wire [31:0] o_pc_w;

  // Instanciación del DUT
  PC uut (
    .clk            (clk_r),
    .i_reset        (i_reset_r),
    .i_jump_address (i_jump_address_r),
    .i_jump         (i_jump_r),
    .i_halt         (i_halt_r),
    .i_stall        (i_stall_r),
    .o_pc           (o_pc_w)
  );

  // Generador de reloj (período = 10 ns)
  initial begin
    clk_r = 0;
    forever #(CLK_PERIOD/2) clk_r = ~clk_r;
  end

  // Tarea auxiliar para avanzar un ciclo de reloj y mostrar o_pc
  task tick_and_display(input [255:0] msg);
  begin
    @(posedge clk_r);
    $display("%0t | %s: o_pc = %0d (0x%0h)", $time, msg, o_pc_w, o_pc_w);
  end
  endtask

  initial begin
    // ------------------------------------------------------------------------
    // 1) RESET inicial
    // ------------------------------------------------------------------------
    i_reset_r        = 0;     // activo-LOW: PC <= 0
    i_jump_r         = 0;
    i_jump_address_r = 0;
    i_halt_r         = 0;
    i_stall_r        = 0;

    // Primer flanco de reloj con reset a 0: fuerza o_pc = 0
    tick_and_display("Tras posedge con i_reset=0");

    // Suelto reset
    i_reset_r = 1;
    tick_and_display("Tras soltar reset");

    // ------------------------------------------------------------------------
    // 2) INCREMENTO NORMAL
    // ------------------------------------------------------------------------
    // Con i_jump=0, i_halt=0, i_stall=0, debe contar +4 cada ciclo
    tick_and_display("Incremento normal 1 (esperado 8)");
    tick_and_display("Incremento normal 2 (esperado 12)");

    // ------------------------------------------------------------------------
    // 3) SALTO (JUMP)
    // ------------------------------------------------------------------------
    // Si i_jump=1 y no hay halt/stall, o_pc <= i_jump_address
    i_jump_address_r = 32'd100;
    i_jump_r         = 1;
    tick_and_display("After jump asserted  (esperado 100)");
    // Desactivo la señal de salto para volver a incrementos normales
    i_jump_r = 0;
    tick_and_display("Post-jump increment   (esperado 104)");

    // ------------------------------------------------------------------------
    // 4) HALT
    // ------------------------------------------------------------------------
    // Mientras i_halt=1, ni salto ni incrementos deben cambiar o_pc
    i_halt_r = 1;

    // Intento incrementar
    tick_and_display("Con HALT, incremento ignorado (esperado 104)");

    // Intento salto durante halt
    i_jump_address_r = 32'd200;
    i_jump_r         = 1;
    tick_and_display("Con HALT+JUMP, salto ignorado   (esperado 104)");
    // Limpio
    i_jump_r = 0;
    i_halt_r = 0;

    // Suelto halt y confirmo que vuelve a incrementar
    tick_and_display("Tras liberar HALT, incremento (esperado 108)");

    // ------------------------------------------------------------------------
    // 5) STALL
    // ------------------------------------------------------------------------
    // Igual que halt: mantiene o_pc constante
    i_stall_r = 1;
    tick_and_display("Con STALL, incremento ignorado (esperado 108)");

    // Intento salto durante stall
    i_jump_address_r = 32'd300;
    i_jump_r         = 1;
    tick_and_display("Con STALL+JUMP, salto ignorado   (esperado 108)");
    // Limpio
    i_jump_r  = 0;
    i_stall_r = 0;

    // Suelto stall y confirmo incremento
    tick_and_display("Tras liberar STALL, incremento (esperado 112)");

    // ------------------------------------------------------------------------
    // 6) RESET en mitad de la operación
    // ------------------------------------------------------------------------
    // Debe volver a 0 inmediatamente
    i_reset_r = 0; 
    @(negedge i_reset_r);  // dispara la rama de reset en el always
    $display("%0t | Tras forzar RESET bajo: o_pc = %0d (esperado 0)", $time, o_pc_w);

    // Suelto reset y veo el primer incremento
    i_reset_r = 1;
    tick_and_display("Tras soltar RESET de nuevo (esperado 4)");

    // ------------------------------------------------------------------------
    // Fin de la simulación
    // ------------------------------------------------------------------------
    #CLK_PERIOD;
    $finish;
  end

endmodule
