
`timescale 1 ns / 100 ps

//�?次保�?20行的16位数�?,240*16*20
//还是�?行吧 240*16 = 480*8
//格式化插�?:SystemVerilog and Verilog Formatter
//lcd_show_ram.v
module lcd_show_ram #(parameter DATA_WDTH = 4'd8,    //输入数据的位深
                      parameter COL = 480,           //RAM中数据个数
                      parameter COL_BITS = 9)
                     (input clk,                     //时钟信号
                      input [COL_BITS-1:0] addra,   //写入数据的地址
                      input [DATA_WDTH-1:0] dina,    //写入的数据
                      input W_EN,                    //写有效
                      input [COL_BITS-1:0] addrb,   //输出数据的地址
                      output [DATA_WDTH-1:0] doutb); //输出的数
    
    reg [DATA_WDTH-1:0] mem[0:COL-1];  //定义RAM
    
    assign doutb = mem[addrb+0];
    
    always @(posedge clk) begin
        if (W_EN == 1'b1)							//写有效时候，把dina写入到addra
        begin
        mem[addra] <= dina;
        end else;
    end
    
endmodule
