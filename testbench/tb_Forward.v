`timescale 1ns / 1ps

module tb_Forward;

    // Parámetros
    localparam NB_ADDR = 5;
    localparam NB_FW   = 2;

    // Entradas
    reg [NB_ADDR-1:0] i_rs_IFID;
    reg [NB_ADDR-1:0] i_rt_IFID;
    reg [NB_ADDR-1:0] i_rd_IDEX;
    reg [NB_ADDR-1:0] i_rd_EX_MEMWB;
    reg               i_wr_WB;
    reg               i_wr_MEM;

    // Salidas
    wire [NB_FW-1:0] o_fw_a;
    wire [NB_FW-1:0] o_fw_b;

    // DUT
    Forward #(
        .NB_ADDR(NB_ADDR),
        .NB_FW(NB_FW)
    ) dut (
        .i_rs_IFID(i_rs_IFID),
        .i_rt_IFID(i_rt_IFID),
        .i_rd_IDEX(i_rd_IDEX),
        .i_rd_EX_MEMWB(i_rd_EX_MEMWB),
        .i_wr_WB(i_wr_WB),
        .i_wr_MEM(i_wr_MEM),
        .o_fw_a(o_fw_a),
        .o_fw_b(o_fw_b)
    );

    initial begin
        $display("⏱️ Testbench Forwarding Unit iniciado");
        
        // Caso 1: Sin Forwarding
        i_rs_IFID = 5'd1;
        i_rt_IFID = 5'd2;
        i_rd_IDEX = 5'd3;
        i_rd_EX_MEMWB = 5'd4;
        i_wr_WB  = 0;
        i_wr_MEM = 0;
        #10;
        $display("❌ Sin Forwarding -> fw_a: %b, fw_b: %b", o_fw_a, o_fw_b);

        // Caso 2: Forward A desde EX_MEM
        i_rs_IFID = 5'd4;
        i_wr_MEM  = 1;
        #10;
        $display("✅ Forward A desde EX_MEM -> fw_a: %b", o_fw_a);

        // Caso 3: Forward B desde MEM/WB
        i_rt_IFID = 5'd3;
        i_wr_MEM  = 0;
        i_wr_WB   = 1;
        i_rd_IDEX = 5'd3;
        #10;
        $display("✅ Forward B desde MEMWB -> fw_b: %b", o_fw_b);

        // Caso 4: Forwarding simultáneo
        i_rs_IFID = 5'd3;
        i_rt_IFID = 5'd4;
        i_rd_IDEX = 5'd3;
        i_rd_EX_MEMWB = 5'd4;
        i_wr_WB  = 1;
        i_wr_MEM = 1;
        #10;
        $display("🔁 Forward A y B simultáneo -> fw_a: %b, fw_b: %b", o_fw_a, o_fw_b);

        #10;
        $finish;
    end

endmodule
