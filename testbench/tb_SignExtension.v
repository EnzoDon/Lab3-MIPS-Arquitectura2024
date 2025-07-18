`timescale 1ns/1ps

module tb_SignExtension;
  // Parámetros
  localparam NB_IMM  = 16;
  localparam NB_DATA = 32;

  // Señales de estímulo (_r)
  reg                 i_immediate_flag_r;
  reg  [NB_IMM-1:0]   i_immediate_value_r;

  // Salida del DUT (_w)
  wire [NB_DATA-1:0]  o_data_w;

  // Instanciación del DUT
  SignExtension #(
    .NB_IMM(NB_IMM),
    .NB_DATA(NB_DATA)
  ) uut (
    .i_immediate_flag (i_immediate_flag_r),
    .i_immediate_value(i_immediate_value_r),
    .o_data           (o_data_w)
  );

  // Tarea para aplicar un caso de prueba
  task test_case(
    input flag,
    input [NB_IMM-1:0]  imm,
    input [NB_DATA-1:0]     exp
  );
  begin
    i_immediate_flag_r  = flag;
    i_immediate_value_r = imm;
    #1; // retardo para propagar la señal combinacional
    if (o_data_w !== exp)
      $error("TEST FAILED: flag=%b imm=0x%04h -> got=0x%08h, expected=0x%08h",
             flag, imm, o_data_w, exp);
    else
      $display("TEST PASSED: flag=%b imm=0x%04h -> 0x%08h",
               flag, imm, o_data_w);
  end
  endtask

  initial begin
    // ------------------------------------------------------------------
    // Casos de prueba: ZERO-EXTENSION (flag=0)
    // ------------------------------------------------------------------
    test_case(0, 16'h0000, 32'h0000_0000); // cero
    test_case(0, 16'h7FFF, 32'h0000_7FFF); // máximo positivo
    test_case(0, 16'h8000, 32'h0000_8000); // MSB=1 pero zero-extend

    // ------------------------------------------------------------------
    // Casos de prueba: SIGN-EXTENSION (flag=1)
    // ------------------------------------------------------------------
    test_case(1, 16'h0001, 32'h0000_0001); // +1
    test_case(1, 16'h7FFF, 32'h0000_7FFF); // +32767
    test_case(1, 16'h8000, 32'hFFFF_8000); // -32768
    test_case(1, 16'hFFFF, 32'hFFFF_FFFF); // -1

    $display("=== Todos los tests de SignExtension pasaron exitosamente ===");
    #1;
    $finish;
  end

endmodule
