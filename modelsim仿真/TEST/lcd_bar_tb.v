`timescale 1ns / 100ps
module lcd_bar_tb;

parameter CLK_PERIOD = 2; 
 
reg clk;
initial clk = 1'b0;
always #(CLK_PERIOD/2) clk = ~clk;

reg rst_n;  //active low
wire    [8:0]   data;
// wire    en_write;
wire    wr_done;
wire    lcd_cs,lcd_dc,lcd_sclk,lcd_mosi;
// wire    [8:0]   init_data;
// wire            en_write_init;
// wire            init_done;
// wire    [8:0]   show_pic_data     ;
wire    show_pic_done;
wire    en_write_show_pic;
// wire    [8:0] col_pos;
wire     [8:0]  rom_addr;
wire     [7:0]  rom_q;
reg  show_pic_flag;

wire [3:0]  register_r;
// reg [8:0] write_test_data;
// integer          i;  
// reg [7:0] mem[0:8];
initial begin
    show_pic_flag=0;
    
    rst_n = 1'b0;
    // write_test_data=9'h123;
    #4;
    show_pic_flag=0;
    rst_n = 1'b1;
    
    #1000;
    show_pic_flag=1;
    // write_test_data=9'h23;
end

lcd_ram u_lcd_ram
(
    .rom_q  (rom_q),
    .rom_addr(rom_addr)
);

lcd_write  lcd_write_inst
(
    .sys_clk_50MHz(clk	  ),
    .sys_rst_n    (rst_n  		  ),
    .data         (data         ),
    .en_write     ( en_write_show_pic ),//en_write_show_pic
                                
    .wr_done      (wr_done      ),
    .cs           (lcd_cs       ),
    .dc           (lcd_dc       ),
    .sclk         (lcd_sclk     ),
    .mosi         (lcd_mosi     )
);

// lcd_init  lcd_init_inst
// (
//     .sys_clk_50MHz(clk		),
//     .sys_rst_n    (rst_n	     ),
//     .wr_done      (wr_done      ),

//     .lcd_rst      (lcd_rst      ),
//     .init_data    (data    ),
//     .en_write     (en_write_init),
//     .init_done    (init_done    )
// );
wire  [3:0] cnt_set_windows;
lcd_show_row u_lcd_show_row
(
    .sys_clk			(clk    ),
    .sys_rst_n        	(rst_n        ),
    .wr_done          	(wr_done      ),
    .show_pic_flag    	(show_pic_flag), 
	.col_pos            (9'd100),//col_pos
    .rom_addr	 		(rom_addr), 
	.rom_q				(rom_q),
	.show_pic_data    	(data     ),   
    .show_pic_done      (show_pic_done),
    .register_r (register_r),
    .cnt_set_windows (cnt_set_windows),
    .en_write_show_pic  (en_write_show_pic )  
);


endmodule