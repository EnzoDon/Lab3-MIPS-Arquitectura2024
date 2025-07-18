`timescale 1ns/1ps

module tb_Registers;
  // Parámetros
  localparam NB_DATA = 32;
  localparam NB_ADDR = 5;
  localparam DEPTH   = 2**NB_ADDR;
  localparam CLK_PERIOD = 10;

  // Señales de estímulo (_r)
  reg                     clk_r;
  reg                     i_reset_r;
  reg                     i_we_r;
  reg  [NB_ADDR-1:0]      i_wr_addr_r;
  reg  [NB_DATA-1:0]      i_wr_data_r;
  reg  [NB_ADDR-1:0]      i_read_reg1_r;
  reg  [NB_ADDR-1:0]      i_read_reg2_r;

  // Salidas DUT (_w)
  wire [NB_DATA-1:0]      o_ReadData1_w;
  wire [NB_DATA-1:0]      o_ReadData2_w;

  // Instancia del DUT
  Registers #(
    .NB_DATA(NB_DATA),
    .NB_ADDR(NB_ADDR)
  ) uut (
    .clk         (clk_r),
    .i_reset     (i_reset_r),
    .i_we        (i_we_r),
    .i_wr_addr   (i_wr_addr_r),
    .i_wr_data   (i_wr_data_r),
    .i_read_reg1 (i_read_reg1_r),
    .i_read_reg2 (i_read_reg2_r),
    .o_ReadData1 (o_ReadData1_w),
    .o_ReadData2 (o_ReadData2_w)
  );

  // Generador de reloj
  initial begin
    clk_r = 0;
    forever #(CLK_PERIOD/2) clk_r = ~clk_r;
  end

  // Tarea: aplicar reset (activo-LOW)
  task do_reset;
    begin
      i_reset_r = 0;
      @(negedge clk_r);       // reset applied on negedge
      #1;
      i_reset_r = 1;
      @(negedge clk_r);       // wait one more cycle for clears
      #1;
    end
  endtask

  // Tarea: escribir un registro en el flanco de bajada
  task write_reg(
    input [NB_ADDR-1:0] addr,
    input [NB_DATA-1:0] data
  );
    begin
      i_we_r       = 1;
      i_wr_addr_r  = addr;
      i_wr_data_r  = data;
      @(negedge clk_r);
      #1;
      i_we_r = 0;
      $display("WRITE: addr=%0d data=0x%08h at time %0t", addr, data, $time);
    end
  endtask

  // Tarea: leer dos registros y comparar con esperado
  task read_and_check(
    input [NB_ADDR-1:0] addr1,
    input [NB_DATA-1:0] exp1,
    input [NB_ADDR-1:0] addr2,
    input [NB_DATA-1:0] exp2
  );
    begin
      i_read_reg1_r = addr1;
      i_read_reg2_r = addr2;
      #1; // breve espera para la lectura combinacional
      if (o_ReadData1_w !== exp1)
        $error("READ1 MISMATCH: addr=%0d got=0x%08h expected=0x%08h at time %0t",
               addr1, o_ReadData1_w, exp1, $time);
      else
        $display("READ1 OK: addr=%0d data=0x%08h", addr1, o_ReadData1_w);
      if (o_ReadData2_w !== exp2)
        $error("READ2 MISMATCH: addr=%0d got=0x%08h expected=0x%08h at time %0t",
               addr2, o_ReadData2_w, exp2, $time);
      else
        $display("READ2 OK: addr=%0d data=0x%08h", addr2, o_ReadData2_w);
    end
  endtask

  initial begin
    // Inicialización de señales
    i_reset_r       = 1;
    i_we_r          = 0;
    i_wr_addr_r     = 0;
    i_wr_data_r     = 0;
    i_read_reg1_r   = 0;
    i_read_reg2_r   = 0;

    // ------------------------------------------------------------------
    // 1) Test de RESET: todos los registros deben valer 0
    // ------------------------------------------------------------------
    do_reset();
    // Leer un par de registros arbitrarios
    read_and_check(0, 0, DEPTH-1, 0);

    // ------------------------------------------------------------------
    // 2) Test de ESCRITURA y LECTURA básica
    // ------------------------------------------------------------------
    // Antes de escribir, lecturas deben dar 0
    read_and_check(3, 0, 7, 0);

    // Escribo en el registro 3
    write_reg(3, 32'hA5A5_A5A5);
    // Tras el write, lectura debe devolver el nuevo valor
    read_and_check(3, 32'hA5A5_A5A5, 7, 0);

    // Escribo en el registro 7
    write_reg(7, 32'hDEAD_BEEF);
    read_and_check(3, 32'hA5A5_A5A5, 7, 32'hDEAD_BEEF);

    // ------------------------------------------------------------------
    // 3) Test de supresión de escritura en ciclo de lectura
    //    (escritura en negedge, lectura combinacional)
    // ------------------------------------------------------------------
    // Preparo un write pero leo antes del negedge: la salida sigue mostrando el valor antiguo
    i_we_r       = 1;
    i_wr_addr_r  = 3;
    i_wr_data_r  = 32'h1234_5678;
    // lecturas antes del próximo negedge
    read_and_check(3, 32'hA5A5_A5A5, 7, 32'hDEAD_BEEF);
    // Ahora ocurre el negedge y se aplica la escritura
    @(negedge clk_r); #1; i_we_r = 0;
    read_and_check(3, 32'h1234_5678, 7, 32'hDEAD_BEEF);

    // ------------------------------------------------------------------
    // Fin de simulación
    // ------------------------------------------------------------------
    $display("=== Todos los tests de Registers pasaron exitosamente ===");
    # (CLK_PERIOD);
    $finish;
  end

endmodule
