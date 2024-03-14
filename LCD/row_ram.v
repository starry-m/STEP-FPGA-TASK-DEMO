`timescale 1 ns / 100 ps
//240*16*20
//240*16 = 480*8
//SystemVerilog and Verilog Formatter
//row_ram.v
module row_ram #(parameter DATA_WDTH = 4'd8,    //
                      parameter COL = 480,           //RAM
                      parameter COL_BITS = 9)
                     (input clk,                     //
                      input [COL_BITS-1:0] addra,    //
                      input [DATA_WDTH-1:0] dina,    //
                      input W_EN, 
                      input Choice,
                      input [COL_BITS-1:0] addrb,    //
                      output reg [DATA_WDTH-1:0] doutb);

reg [DATA_WDTH-1:0] mem[0:COL-1];  
// reg [DATA_WDTH-1:0] mem2[0:COL-1];
// assign doutb = mem[addrb+0];
// wire [1:0]temp={Choice,W_EN};
always @(posedge clk) begin
    if(W_EN)
        mem[addra] <= dina;
    else
        doutb <= mem[addrb];
end
// always @(posedge clk) begin
//     if(W_EN==1'b1 && Choice==1'b0)
//         mem[addra] <= dina;
//     else if(W_EN==1'b1 && Choice==1'b1)
//         mem2[addra] <= dina;
//     else if(W_EN==1'b0 && Choice==1'b0)
//         doutb <= mem[addrb];
//     else if(W_EN==1'b0 && Choice==1'b1)
//         doutb <= mem2[addrb];
//     else 
//         doutb <= mem[addrb];

// end 

endmodule
