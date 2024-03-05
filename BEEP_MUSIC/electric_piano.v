// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: electric_piano
// 
// Author: Step
// 
// Description: ¾ØÕó¼üÅÌ¹¹³É¼òÒ×µç×ÓÇÙ£¬Çý¶¯·äÃùÆ÷·¢Éù
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module electric_piano(
		input				clk,			//system clock
		input				rst_n,		//system reset
		input		[3:0]	col,
		output	[3:0]	row,
		output			beeper
	);  

wire			[15:0]	key_out;
wire			[15:0]	key_pulse;
//Array_KeyBoard 
array_keyboard u1(
		.clk(clk),
		.rst_n(rst_n),
		.col(col),
		.row(row),
		.key_out(key_out),
		.key_pulse(key_pulse)
	);

//beeper module
beeper u2(
		.clk(clk),
		.rst_n(rst_n),
		.key_out(~key_out),
		.beeper(beeper)
	);

endmodule
