module Registers
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5
)(
    input wire              clk                         ,
    input wire              i_reset                     ,
    
    //write
    input wire                i_we                          ,
    input wire  [NB_ADDR-1:0] i_wr_addr                   ,
    input wire  [NB_DATA-1:0] i_wr_data                   ,
    
    //read               
    input wire  [NB_ADDR-1:0] i_read_reg1                  ,
    input wire  [NB_ADDR-1:0] i_read_reg2                  ,

    output wire [NB_DATA-1:0] o_ReadData1                  ,
    output wire [NB_DATA-1:0] o_ReadData2
);

    reg [NB_DATA-1:0] registers[2**NB_ADDR-1:0]          ;
    integer i;


    //! writing block
    always @(negedge clk or negedge i_reset)
    begin
        if(~i_reset)
        begin
            for( i = 0; i < 2**NB_ADDR; i = i+1)
            begin
                registers[i] <= 0                        ;
            end
        end
        else
        begin
            if(i_we)
            begin
                registers[i_wr_addr] <= i_wr_data        ;
            end
        end
    end
    
    /*
        La escritura es secuencial y ocurre al final del ciclo. 
        Así, si en el mismo ciclo una instrucción escribe a $t0 y la siguiente lee $t0, esta aún ve el valor viejo, lo cual es lo esperado.
        Por eso en este modulo para la escritura debemos usar el flanco de bajada. Contrario al resto donde se usa el de subida.
    */

    assign o_ReadData1 = registers[i_read_reg1]            ; //La lectura es combinacional
    assign o_ReadData2 = registers[i_read_reg2]            ;

endmodule