`timescale 1ns/1ps

module tb_RAM;
  // Parámetros
  localparam NB_DATA    = 32;
  localparam NB_ADDR    = 8;
  localparam CLK_PERIOD = 10;

  // Señales de estímulo (registros)
  reg                     clk_r;
  reg                     i_write_enable_r;
  reg  [NB_DATA-1:0]      i_data_r;
  reg  [NB_ADDR-1:0]      i_addr_w_r;

  // Salida del DUT (wire)
  wire [NB_DATA-1:0]      o_data_w;

  // Instanciación del DUT
  RAM #(
    .NB_DATA(NB_DATA),
    .NB_ADDR(NB_ADDR)
  ) uut (
    .clk             (clk_r),
    .i_write_enable  (i_write_enable_r),
    .i_data          (i_data_r),
    .i_addr_w        (i_addr_w_r),
    .o_data          (o_data_w)
  );

  // 1) Generador de reloj
  initial begin
    clk_r = 0;
    forever #(CLK_PERIOD/2) clk_r = ~clk_r;
  end

  // 2) Secuencia de prueba
  initial begin
    // Inicialización
    i_write_enable_r = 1;
    i_data_r         = 0;
    i_addr_w_r       = 0;
    // Dejo que el DUT estabilice
    #(CLK_PERIOD * 2);

    // Escribo varias direcciones
    write_word(8,  32'hDEAD_BEEF);
    write_word(16, 32'hCAFEBABE);
    write_word(32, 32'h12345678);

    #CLK_PERIOD;
    
    // Leo varias direcciones   
    i_write_enable_r = 0; 
    read_word (8,  32'hDEAD_BEEF);
    read_word (16, 32'hCAFEBABE);
    read_word (32, 32'h12345678);
    // Terminar simulación
    #CLK_PERIOD;
    $finish;
  end

  // Tarea: escribir una palabra en memoria
  task write_word(
    input [NB_ADDR-1:0] addr,
    input [NB_DATA-1:0] data
  );
    begin
      i_addr_w_r       = addr;
      i_data_r         = data;
      #CLK_PERIOD;
      $display("TIME=%0t: WRITE @%0d <= 0x%08h", $time, addr, data);
    end
  endtask

  // Tarea: leer una palabra y verificarla
  task read_word(
    input [NB_ADDR-1:0] addr,
    input [NB_DATA-1:0] exp_data
  );
    begin
      i_addr_w_r = addr;
      #1; // espera la lectura combinacional
      if (o_data_w !== exp_data)
        $error("TIME=%0t: READ MISMATCH @%0d, got=0x%08h expected=0x%08h",
                $time, addr, o_data_w, exp_data);
      else
        $display("TIME=%0t: READ OK @%0d => 0x%08h", $time, addr, o_data_w);
    end
  endtask

endmodule
