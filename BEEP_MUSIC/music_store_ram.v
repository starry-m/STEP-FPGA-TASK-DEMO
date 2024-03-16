`timescale 1 ns / 100 ps
//
//
//SystemVerilog and Verilog Formatter
//music_store_ram.v
// 48+36=84
module music_store_ram #(parameter DATA_WDTH = 4'd5,    //
                      parameter COL = 100,           //RAM
                      parameter COL_BITS = 8)
                     (input clk,                     //
                      input [COL_BITS-1:0] addra,    //
                      input [DATA_WDTH-1:0] dina,    //
                      input W_EN, 
                      input [COL_BITS-1:0] addrb,    //
                      output reg [DATA_WDTH-1:0] doutb);

reg [DATA_WDTH-1:0] mem[0:COL-1];  

always @(posedge clk) begin
    if(W_EN)
        mem[addra] <= dina;
    else
        doutb <= mem[addrb];
end


endmodule
