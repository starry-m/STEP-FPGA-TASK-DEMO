// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: electric_piano
// 
// Author: Step
// 
// Description: 矩阵键盘构成简易电子琴，驱动蜂鸣器发声
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

		output reg  [7:0]	addr,
		input    [4:0]	 data,
		input 	songs_choose,
		
		output			beeper
	);  




//beeper module
// beeper u2(
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.key_out(~key_out),
// 		.beeper(beeper)
// 	);

wire [15:0]	cycle;
reg	 [4:0]	note_c;
// reg  [7:0]	addr;
// wire  [4:0]	data;
reg no_flag;
reg [23:0]cnt_1s;

music_to_tone u2(
		.choose(note_c),
		.cycle(cycle)
);

//根据不同音节的周期cycle值产生对应的PWM信号
pwm #(
		.WIDTH(16)			//ensure that 2**WIDTH > cycle
	) u3(
		.clk(clk),
		.rst_n(rst_n),
		.cycle(cycle),		//cycle > duty
		.duty(cycle>>1),	//duty=cycle/2,产生50%占空比
		.pwm_out(beeper)
);

// music_rom u4(
// .address(addr),
// .data(data)
// );
//songs_choose 
reg [1:0]songs_temp; 
always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		songs_temp <=0;
	else if(songs_temp[0] !=songs_choose)
		songs_temp <= {songs_temp[0],songs_choose};
	else
		songs_temp <=songs_temp ;
always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		note_c <= 5'd0;
	else if(no_flag)
		note_c <= data;
	else if(no_flag == 1'd0)
		note_c <= 5'd0;
	else 
		note_c <= note_c;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		addr <= 8'b0;
	else if(songs_temp[0] != songs_choose)
		addr <= songs_choose ? 8'd48 : 8'b0;

	else if(addr == 8'd47 && !songs_choose&& cnt_1s == 32'd9599999) 
		addr <= 8'b0;//0-47
	
	else if(addr == 8'd83 && songs_choose&& cnt_1s == 32'd9599999) 
		addr <= 8'd48;//48-83

	else if(cnt_1s == 32'd9599999) 
		addr <= addr+1'b1;
	else 
		addr  <= addr;

// always @(posedge clk or negedge rst_n)
// 	if(!rst_n) 
// 		addr <= 8'b0;
// 	else if(addr == 8'd47 && cnt_1s == 32'd9599999) 
// 		addr <= 8'b0;
// 	else if(cnt_1s == 32'd9599999) 
// 		addr <= addr+1'b1;
// 	else 
// 		addr <= addr;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		cnt_1s <= 24'd0;
	else if(cnt_1s == 32'd11999999)
        cnt_1s <= 24'd0;
	
	else if(cnt_1s < 32'd11999999)
		cnt_1s <= cnt_1s +1'd1;
	else
		cnt_1s <= cnt_1s;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		no_flag<= 1'b0;
	else if(cnt_1s == 32'd0)
		no_flag <=1'b1;
	else if(cnt_1s == 32'd9599999)
		no_flag <=1'b0;

	else
	no_flag<= no_flag;



	
endmodule
