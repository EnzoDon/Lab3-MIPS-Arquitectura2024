`timescale 1ns / 1ps

module tb_EX_Stage;

    // Parámetros
    localparam NB_DATA = 32;
    localparam NB_ADDR = 5;

    // Entradas
    reg clk;
    reg i_reset;
    reg i_step;

    reg [4:0] i_rt;
    reg [4:0] i_rd;
    reg [NB_DATA-1:0] i_reg_DA;
    reg [NB_DATA-1:0] i_reg_DB;
    reg [NB_DATA-1:0] i_immediate;
    reg [5:0] i_opcode;
    reg [4:0] i_shamt;
    reg [5:0] i_func;

    reg i_regDst;
    reg i_mem2reg;
    reg i_memRead;
    reg i_memWrite;
    reg i_immediate_flag;
    reg i_regWrite;
    reg [1:0] i_aluOP;
    reg [1:0] i_width;
    reg i_sign_flag;

    reg [1:0] i_fw_a;
    reg [1:0] i_fw_b;
    reg [NB_DATA-1:0] i_output_MEMWB;
    reg [NB_DATA-1:0] i_output_EXMEM;

    // Salidas
    wire o_mem2reg;
    wire o_memWrite;
    wire o_regWrite;
    wire [1:0] o_width;
    wire o_sign_flag;
    wire [4:0] o_write_reg;
    wire [NB_DATA-1:0] o_data4Mem;
    wire [NB_DATA-1:0] o_result;

    // Instanciar el módulo
    EX_Stage uut (
        .clk(clk),
        .i_reset(i_reset),
        .i_step(i_step),
        .i_rt(i_rt),
        .i_rd(i_rd),
        .i_reg_DA(i_reg_DA),
        .i_reg_DB(i_reg_DB),
        .i_immediate(i_immediate),
        .i_opcode(i_opcode),
        .i_shamt(i_shamt),
        .i_func(i_func),
        .i_regDst(i_regDst),
        .i_mem2reg(i_mem2reg),
        .i_memRead(i_memRead),
        .i_memWrite(i_memWrite),
        .i_immediate_flag(i_immediate_flag),
        .i_regWrite(i_regWrite),
        .i_aluOP(i_aluOP),
        .i_width(i_width),
        .i_sign_flag(i_sign_flag),
        .i_fw_a(i_fw_a),
        .i_fw_b(i_fw_b),
        .i_output_MEMWB(i_output_MEMWB),
        .i_output_EXMEM(i_output_EXMEM),
        .o_mem2reg(o_mem2reg),
        .o_memWrite(o_memWrite),
        .o_regWrite(o_regWrite),
        .o_width(o_width),
        .o_sign_flag(o_sign_flag),
        .o_write_reg(o_write_reg),
        .o_data4Mem(o_data4Mem),
        .o_result(o_result)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Test
    initial begin
        $display("⏱️ Comienza el test de la etapa EX");

        // Inicialización
        clk = 0;
        i_reset = 0;
        i_step = 0;

        i_rt = 5'd2;
        i_rd = 5'd3;
        i_reg_DA = 32'd10;
        i_reg_DB = 32'd5;
        i_immediate = 32'd100;
        i_opcode = 6'b000000; // R-Type
        i_shamt = 5'd0;
        i_func = 6'b100000; // ADD
        i_regDst = 0;
        i_mem2reg = 0;
        i_memRead = 0;
        i_memWrite = 0;
        i_immediate_flag = 0;
        i_regWrite = 1;
        i_aluOP = 2'b10; // R-type
        i_width = 2'b00;
        i_sign_flag = 0;

        i_fw_a = 2'b00;
        i_fw_b = 2'b00;
        i_output_MEMWB = 32'd0;
        i_output_EXMEM = 32'd0;

        // Reset
        #5 i_reset = 1;

        // Caso 1: operación normal sin forwarding
        #10;
        $display("▶️ Sin Forwarding: o_result = %d", o_result);

        // Caso 2: FORWARD A desde EXMEM (i_fw_a = 2'b11)
        i_func = 6'b100010; // SUB
        i_fw_a = 2'b11;
        i_output_EXMEM = 32'd40;

        #10;
        $display("▶️ Forward A desde EXMEM (rs): o_result = %d", o_result);

        // Caso 3: FORWARD B desde MEMWB (i_fw_b = 2'b10)
        i_func = 6'b100100; // AND
        i_fw_b = 2'b10;
        i_output_MEMWB = 32'hFFFFFFFF;

        #10;
        $display("▶️ Forward B desde MEMWB (rt): o_result = %h", o_result);

        // Caso 4: Immediate operand
        i_immediate_flag = 1;
        i_opcode = 6'b001000; // ADDI
        i_func = 6'b000000;
        i_aluOP = 2'b11;

        #10;
        $display("▶️ ADDI immediate: o_result = %d", o_result);

        // Fin
        #10;
        $finish;
    end

endmodule
