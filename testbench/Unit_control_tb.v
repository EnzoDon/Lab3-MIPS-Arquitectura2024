`timescale 1ns/1ps

module tb_Unit_Control;
  // Parámetro
  localparam NB_OP = 6;

  // Señales de estímulo
  
  /** 
      Todas las señales que yo controle y setee el valor van como registros.
      Todas las señales que no controle, es decir, que su valor dependerá de la ejecución (segun el input que le haya seteado en los registros) se declaran como wires.
  */
  
  /*
    En las señales de simulacion puedo ver también las señales internas de los modulos. Lo defino en la ventana scope
  
  */
  reg                   clk_r;
  reg                   reset_r; //reset_r
  reg   [NB_OP-1:0]     opcode_r;
  reg   [NB_OP-1:0]     funct_r;

  // Señales de salida
  wire                  jump_w;
  wire  [1:0]           aluSrc_w;
  wire  [1:0]           aluOp_w;
  wire                  branch_w;// branch_w
  wire                  regDst_w;
  wire                  mem2Reg_w;
  wire                  regWrite_w;
  wire                  memRead_w;
  wire                  memWrite_w;
  wire  [1:0]           width_w;
  wire                  sign_flag_w;
  wire                  immediate_w;

  // Instanciación del DUT
  Unit_Control #(.NB_OP(NB_OP)) DUT (
    .clk        (clk_r),
    .i_reset    (reset_r),
    .i_opcode   (opcode_r),
    .i_funct    (funct_r),
    .o_jump     (jump_w),
    .o_aluSrc   (aluSrc_w),
    .o_aluOp    (aluOp_w),
    .o_branch   (branch_w),
    .o_regDst   (regDst_w),
    .o_mem2Reg  (mem2Reg_w),
    .o_regWrite (regWrite_w),
    .o_memRead  (memRead_w),
    .o_memWrite (memWrite_w),
    .o_width    (width_w),
    .o_sign_flag(sign_flag_w),
    .o_immediate(immediate_w)
  );

  // Generador de reloj
  initial begin
    clk_r = 0;
    forever #5 clk_r = ~clk_r; // Período de 10 ns
  end

  // Secuencia de pruebas
  initial begin
    // Inicialización y reset
    reset_r = 1;
    opcode_r = 0;
    funct_r  = 0;
    #20;
    reset_r = 0;

    // Vector de pruebas: {opcode, funct}
    // R-TYPE (funciones: ejemplo JR=001000, JARL=001001)
    apply(6'b000000, 6'b100000); // ADD
    apply(6'b000000, 6'b001000); // JR
    apply(6'b000000, 6'b001001); // JARL

    // LW
    apply(6'b100011, 6'b000000);
    // SW
    apply(6'b101011, 6'b000000);
    // BEQ
    apply(6'b000100, 6'b000000);
    // BNE
    apply(6'b000101, 6'b000000);
    // ADDI
    apply(6'b001000, 6'b000000);
    // ORI
    apply(6'b001101, 6'b000000);
    // ANDI
    apply(6'b001100, 6'b000000);
    // XORI
    apply(6'b001110, 6'b000000);
    // LUI
    apply(6'b001111, 6'b000000);
    // J
    apply(6'b000010, 6'b000000);
    // JAL
    apply(6'b000011, 6'b000000);

    // Terminar la simulación
    #20;
    $finish;
  end

  // Tarea para aplicar un vector de estímulo y mostrar salidas
  task apply(input [NB_OP-1:0] opc, input [NB_OP-1:0] fn);
  begin
    opcode_r = opc;
    funct_r  = fn;
    #10; // Esperar medio ciclo de reloj
    $display("TIME=%0t | opc=%b fn=%b | jump=%b aluSrc=%b aluOp=%b branch=%b regDst=%b mem2Reg=%b regW=%b memR=%b memW=%b width=%b sign=%b imm=%b",
             $time, opcode_r, funct_r,
             jump_w, aluSrc_w, aluOp_w, branch_w,
             regDst_w, mem2Reg_w, regWrite_w,
             memRead_w, memWrite_w, width_w,
             sign_flag_w, immediate_w);
    #10; // Esperar el resto del ciclo
  end
  endtask

endmodule

