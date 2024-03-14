// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: picture_display
// 
// Author: Step
// 
// Description: LCDͼƬ��ʾ
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2023/10/30   |Initial ver
// --------------------------------------------------------------------

module  picture_display
(
    input           	clk			,
    input               clk_50MHz,
    input           	rst_n		   ,
    
    input               uart_rx,
    output              uart_tx,
    output          	lcd_rst     ,
	output				lcd_blk		,
    output          	lcd_dc      ,
    output          	lcd_sclk    ,
    output          	lcd_mosi    ,
    output          	lcd_cs      

);
wire    [8:0]   data;   
wire            en_write;
wire            wr_done; 

wire    [8:0]   init_data;
wire            en_write_init;
wire            init_done;

wire            en_size            ;
wire            show_pic_flag     ;
wire    [6:0]   ascii_num          ;
wire    [8:0]   start_x            ;
wire    [8:0]   start_y            ;

wire    [8:0]   show_pic_data     ;
wire            en_write_show_pic  ;
wire            show_char_done     ;  
wire     [8:0]  rom_addr;
wire    [7:0]   rom_q;//239
// wire				 clk_50MHz;
wire show_pic_done;
wire [8:0]col_pos;
assign			lcd_blk = 1'b1;


wire rx_data_valid;
wire [7:0]	rx_data_out;
wire tx_data_valid;
wire [7:0]	tx_data_in;

// wire show_row_done;
wire W_EN;
wire row_finished_flag;
uart_bus u1(	
		.clk(clk),							//系统时钟 12MHz
		.rst_n(rst_n),						//系统复位，低有效
		.uart_rx(uart_rx),				//UART接收输入
		.rx_data_valid(rx_data_valid),//接收数据有效脉冲
		.rx_data_out(rx_data_out),		//接收到的数据

        .tx_data_valid(tx_data_valid),	//发送数据有效脉�
		.tx_data_in(tx_data_in),		//要发送的数据
		.uart_tx(uart_tx)			//UART发送输�
	);

// pll pll_u1(
 
// 		.CLKI(clk ), 
// 		.CLKOP(clk_50MHz )
// 	);
// assign clk_50MHz=clk;
lcd_write  lcd_write_inst
(
    .sys_clk_50MHz(clk_50MHz	  ),
    .sys_rst_n    (rst_n  		  ),
    .data         (data         ),
    .en_write     (en_write     ),
                                
    .wr_done      (wr_done      ),
    .cs           (lcd_cs       ),
    .dc           (lcd_dc       ),
    .sclk         (lcd_sclk     ),
    .mosi         (lcd_mosi     )
);

control  control_inst
(
    .sys_clk_50MHz          (clk_50MHz 	       ), 
    .sys_rst_n              (rst_n		          ),
    .init_data              (init_data           ),
    .en_write_init          (en_write_init       ),
    .init_done              (init_done           ),
    .show_pic_data         (show_pic_data      ),
    .en_write_show_pic     (en_write_show_pic  ),

    .show_pic_done   (show_pic_done),
    // .col_pos  (col_pos),
	.show_pic_flag	      (show_pic_flag     ),
    .data                   (data                ),
    .en_write               (en_write            )
);

lcd_init  lcd_init_inst
(
    .sys_clk_50MHz(clk_50MHz		),
    .sys_rst_n    (rst_n	     ),
    .wr_done      (wr_done      ),

    .lcd_rst      (lcd_rst      ),
    .init_data    (init_data    ),
    .en_write     (en_write_init),
    .init_done    (init_done    )
);

reg show_temp;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        show_temp <= 1'b0;
    else if(show_pic_flag)
        show_temp <= 1'b1;
    else if(row_finished_flag)
        show_temp <= 1'b0;
    else
    show_temp <=show_temp;


lcd_show_row u_lcd_show_row
(
    .sys_clk			(clk_50MHz    ),
    .sys_rst_n        	(rst_n        ),
    .wr_done          	(wr_done      ),
    .show_pic_flag    	(show_temp && row_finished_flag), 
	.col_pos  (col_pos),
	.rom_addr	 		(rom_addr), 
	.rom_q				(rom_q),
	.show_pic_data    	(show_pic_data     ),   
    .en_write_show_pic  (en_write_show_pic ),
    .show_pic_done   (show_pic_done)  
);




uart_to_ram  u_uart_to_ram
(
    .clk_12m(clk),
    .clk(clk_50MHz),
    .rst_n(rst_n),
    .rx_data_valid(rx_data_valid),
    .rx_data_out(rx_data_out),
    .addr_out_index(rom_addr),
    .show_row_done(show_pic_done),
    .tx_data_valid(tx_data_valid),
    .tx_data_out(tx_data_in),
    .out_data(rom_q),
    .col_pos(col_pos),
    .W_EN(W_EN),
    .row_finished_flag(row_finished_flag)
                   );
// lcd_show_pic  lcd_show_pic_inst
// (
//     .sys_clk			(clk_50MHz    ),
//     .sys_rst_n        	(rst_n        ),
//     .wr_done          	(wr_done      ),
//     .show_pic_flag    	(show_pic_flag), 
// 	.rom_addr	 		(rom_addr), 
// 	.rom_q				(240'hF1F1F1),//rom_q
// 	.show_pic_data    	(show_pic_data     ),   
//     .en_write_show_pic  (en_write_show_pic )  
// );
// pic_ram pic_ram_u0
// (
// 	.address(rom_addr), 
// 	.q(rom_q)
// );

// lcd_show_row u_lcd_show_row
// (
//     .sys_clk			(clk_50MHz    ),
//     .sys_rst_n        	(rst_n        ),
//     .wr_done          	(wr_done      ),
//     .show_pic_flag    	(show_pic_flag), 
// 	.col_pos  (col_pos),
// 	.rom_addr	 		(rom_addr), 
// 	.rom_q				(rom_q),
// 	.show_pic_data    	(show_pic_data     ),   
//     .en_write_show_pic  (en_write_show_pic ),
//     .show_pic_done   (show_pic_done)  
// );

// lcd_ram u_lcd_ram
// (
//     .rom_q  (rom_q),
//     .rom_addr(rom_addr)
// );





endmodule