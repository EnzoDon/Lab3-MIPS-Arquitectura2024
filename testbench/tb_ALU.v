`timescale 1ns / 1ps

module tb_ALU;

    // Parámetros
    parameter NB_DATA = 32;
    parameter NB_OP   = 6;

    // Entradas a la ALU
    reg signed [NB_DATA-1:0] i_data_a;
    reg signed [NB_DATA-1:0] i_data_b;
    reg        [NB_OP-1:0]   i_op;
    reg signed [4:0]         i_shamt;

    // Salida
    wire signed [NB_DATA-1:0] o_data;

    // Instanciamos la ALU
    ALU #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) dut (
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_op(i_op),
        .i_shamt(i_shamt),
        .o_data(o_data)
    );

    // Procedimiento de prueba
    initial begin
        $display("⏱️ Comienza el test de la ALU\n");

        // Test 1: ADD
        i_data_a = 10; i_data_b = 5; i_op = 6'b100000; i_shamt = 0; #10;
        $display("ADD:     10 + 5  = %0d", o_data);

        // Test 2: SUB
        i_data_a = 15; i_data_b = 20; i_op = 6'b100010; i_shamt = 0; #10;
        $display("SUB:     15 - 20 = %0d", o_data);

        // Test 3: AND
        i_data_a = 32'hFF00FF00; i_data_b = 32'h0F0F0F0F; i_op = 6'b100100; #10;
        $display("AND:     FF00FF00 & 0F0F0F0F = %h", o_data);

        // Test 4: SLT
        i_data_a = -5; i_data_b = 7; i_op = 6'b101010; #10;
        $display("SLT:     -5 < 7 = %0d", o_data);

        // Test 5: SLL (shift left logical)
        i_data_a = 0; i_data_b = 32'h00000001; i_op = 6'b000000; i_shamt = 4; #10;
        $display("SLL:     1 << 4 = %0d", o_data);

        // Test 6: SLLV (shift left variable)
        i_data_a = 3; i_data_b = 32'h00000001; i_op = 6'b000100; i_shamt = 0; #10;
        $display("SLLV:    1 << 3 = %0d", o_data);

        // Test 7: SLTU (unsigned less-than)
        i_data_a = 32'hFFFFFFFF; i_data_b = 32'h00000001; i_op = 6'b101011; #10;
        $display("SLTU:    FFFFFFFF < 00000001 (unsigned) = %0d", o_data);

        // Test 8: LUI (load upper immediate)
        i_data_a = 0; i_data_b = 32'h00001234; i_op = 6'b001111; #10;
        $display("LUI:     0x1234 << 16 = %h", o_data);

        // Test 9: XORI
        i_data_a = 32'hF0F0F0F0; i_data_b = 32'h0F0F0F0F; i_op = 6'b001110; #10;
        $display("XORI:    F0F0F0F0 ^ 0F0F0F0F = %h", o_data);

        $display("\n✅ Test de ALU finalizado.");
        $finish;
    end

endmodule
