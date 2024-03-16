
`timescale 1 ns / 100 ps

//240*16*20
//240*16 = 480*8
//SystemVerilog and Verilog Formatter
//lcd_show_ram.v
module lcd_show_ram #(parameter DATA_WDTH = 4'd8,    //??
                      parameter COL = 480,           //RAM
                      parameter COL_BITS = 9)
                     (input clk,                     //
                      input [COL_BITS-1:0] addra,    //
                      input [DATA_WDTH-1:0] dina,    //
                      input W_EN,                    //
                      input [COL_BITS-1:0] addrb,    //
                      output reg [DATA_WDTH-1:0] doutb);

reg [DATA_WDTH-1:0] mem[0:COL-1];  //

// assign doutb = mem[addrb+0];

always @(posedge clk) begin
    if (W_EN == 1'b1)
        mem[addra] <= dina;
    else
        doutb <= mem[addrb+0];
end

endmodule
