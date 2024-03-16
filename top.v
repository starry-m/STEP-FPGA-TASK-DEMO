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

input				uart_rx,		//UART
output				uart_tx,
output				seg_rck,		//74HC595
output				seg_sck,		//74HC595
output				seg_din,		//74HC595

input		[3:0]	col,
output	    [3:0]	row,
output led_song,
output			    beeper
);
wire  clk_48m;//actual 48m

pll u_pll(.CLKI(clk_12m ), .CLKOP(clk_48m ));
//�����ļ�
//#(.CNT_1S ( 19 ))
LED_shining  u_LED_shining (
    .clk                     ( clk_12m     ),
    .rst_n                   ( rst_n   ),
 
    .led1                    ( led1  ),
    .led2                    (     )
);

LED_shining  u2_LED_shining (
    .clk                     (  clk_48m     ),
    .rst_n                   ( rst_n   ),
 
    .led1                    (  led2  ),
    .led2                    (     )
);
wire rx_data_valid;
wire [7:0]	rx_data_out;
wire tx_data_valid;
wire [7:0]	tx_data_in;

picture_display u_picture_display(
    .clk		( clk_12m)	,
    .clk_50MHz ( clk_48m)	,
    .rst_n		 (rst_n)  ,
	
 //   .uart_rx    (uart_rx),
//    .uart_tx    (uart_tx),
    .rx_data_valid(rx_data_valid),
    .rx_data_out(rx_data_out),
    .tx_data_valid(tx_data_valid),
    .tx_data_in(tx_data_in),

    .lcd_rst     (lcd_rst),
	.lcd_blk	(lcd_blk)	,
    .lcd_dc      (lcd_dc),
    .lcd_sclk    (lcd_sclk),
    .lcd_mosi    (lcd_mosi),
    .lcd_cs  (lcd_cs)
);
In_Out_Handle  u_In_Out_Handle(
    .clk(clk_12m),
    .rst_n(rst_n),
    .col(col),
    .row(row),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .rx_data_valid_temp(rx_data_valid),
    .rx_data_out_temp(rx_data_out),
    .tx_data_valid_temp(tx_data_valid),
    .tx_data_in_temp(tx_data_in),
    .led_song(led_song),
    .beeper(beeper)
);

// display_ctl u_display_ctl(
//     .clk(clk_12m),			
// 	.rst_n(rst_n),		

// 	.uart_rx(uart_rx),		//UART��������

// 	.seg_rck(seg_rck),		//74HC595��RCK�ܽ�
// 	.seg_sck(seg_sck),		//74HC595��SCK�ܽ�
// 	.seg_din(seg_din)		//74HC595��SER�ܽ�
// );


// electric_piano u_electric_piano(
//     .clk(clk_12m),			//system clock
//     .rst_n(rst_n),		//system reset
// 	.col(col),
// 	.row(row),
// 	.beeper(beeper)
// );

endmodule
