`timescale 1ns/1ps

module clk_wiz_0 (
    input  wire resetn,    // activo-alto para liberar reset
    input  wire clk_in1,   // 100 MHz
    output wire clk_out1   // 45 MHz
);

  // Señales internas para el PLL
  wire clkfb;
  wire clkfb_buf;
  wire clk_pll_out;

  // Instancia del PLLE2_BASE para Artix-7 / 7-series
  PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKIN1_PERIOD     (10.0),  // periodo de entrada = 10 ns → 100 MHz
    .DIVCLK_DIVIDE     (1),     // sin pre-división
    .CLKFBOUT_MULT_F   (9.0),   // VCO = 100 MHz × 9 = 900 MHz
    .CLKOUT0_DIVIDE_F  (20.0),  // CLKOUT0 = 900 MHz / 20 = 45 MHz
    .CLKOUT0_PHASE     (0.0),
    .CLKOUT0_DUTY_CYCLE(0.5)
  ) pll_inst (
    .CLKIN1  (clk_in1),
    .CLKFBIN (clkfb_buf),
    .RST     (~resetn),   // activo-alto para reset en PLLE2
    .PWRDWN  (1'b0),
    .CLKFBOUT(clkfb),
    .CLKOUT0 (clk_pll_out),
    .LOCKED  ()           // no usado
  );

  // Buffer para la señal de feedback
  BUFG fb_bufg (
    .I(clkfb),
    .O(clkfb_buf)
  );

  // Buffer para la salida de 45 MHz
  BUFG out_bufg (
    .I(clk_pll_out),
    .O(clk_out1)
  );

endmodule
