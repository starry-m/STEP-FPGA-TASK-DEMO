module top (
input clk_12m,      //clk = 12mhz
input rst_n,    //rst_n, active low
output led1,    //led1 output
output led2,     //led2 output
output          	lcd_rst     ,
output				lcd_blk		,
output          	lcd_dc      ,
output          	lcd_sclk    ,
output          	lcd_mosi    ,
output          	lcd_cs   ,

input				uart_rx,		//UART接收输入

output				seg_rck,		//74HC595的RCK管脚
output				seg_sck,		//74HC595的SCK管脚
output				seg_din		//74HC595的SER管脚
);
wire clk_60m;//actual 48m
pll u_pll(.CLKI(clk_12m ), .CLKOP( clk_60m));
//顶层文件
//#(.CNT_1S ( 19 ))
LED_shining  u_LED_shining (
    .clk                     ( clk_12m     ),
    .rst_n                   ( rst_n   ),
 
    .led1                    ( led1  ),
    .led2                    (     )
);

LED_shining  u2_LED_shining (
    .clk                     ( clk_60m     ),
    .rst_n                   ( rst_n   ),
 
    .led1                    (  led2  ),
    .led2                    (     )
);
picture_display u_picture_display(
    .clk		(clk_60m)	,
    .rst_n		 (rst_n)  ,
	
    .lcd_rst     (lcd_rst),
	.lcd_blk	(lcd_blk)	,
    .lcd_dc      (lcd_dc),
    .lcd_sclk    (lcd_sclk),
    .lcd_mosi    (lcd_mosi),
    .lcd_cs  (lcd_cs)
);
display_ctl u_display_ctl(
    .clk(clk_12m),			
	.rst_n(rst_n),		

	.uart_rx(uart_rx),		//UART接收输入

	.seg_rck(seg_rck),		//74HC595的RCK管脚
	.seg_sck(seg_sck),		//74HC595的SCK管脚
	.seg_din(seg_din)		//74HC595的SER管脚
);
endmodule
