`timescale 1ns / 100ps
module beep_music_tb();
parameter CLK_PERIOD = 2; 
 
reg clk;
initial clk = 1'b0;
always #(CLK_PERIOD/2) clk = ~clk;
reg songs_choose;
initial songs_choose =1;
reg rst_n;  //active low
initial begin
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;



	
end

wire beeper;
wire [15:0]	cycle;
reg	 [4:0]	note_c;
reg  [7:0]	addr;
wire  [4:0]	data;
reg no_flag;

reg [23:0]cnt_1s;
//将按键信息译成音节对应的周期cycle值
music_to_tone u2(
		.choose(note_c),
		.cycle(cycle)
);

//根据不同音节的周期cycle值产生对应的PWM信号
pwm #(
		.WIDTH(8)			//ensure that 2**WIDTH > cycle
	) u3(
		.clk(clk),
		.rst_n(rst_n),
		.cycle(cycle),		//cycle > duty
		.duty(cycle>>1),	//duty=cycle/2,产生50%占空比
		.pwm_out(beeper)
);

music_rom u4(
.address(addr),
.data(data)
);

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
	else if(addr == 8'd47 && !songs_choose&& cnt_1s == 32'd95999) 
		addr <= 8'b0;//0-47
	
	else if(addr == 8'd83 && songs_choose&& cnt_1s == 32'd95999) 
		addr <= 8'd48;//48-83

	else if(cnt_1s == 32'd95999) 
		addr <= addr+1'b1;
	else 
		addr  <= addr;
// always @(posedge clk or negedge rst_n)
// 	if(!rst_n) 
// 		addr <= 8'b0;
//     else if(addr == 8'd47 && cnt_1s == 32'd95999) 
// 		addr <= 8'b0;
// 	else if(cnt_1s == 32'd95999) 
// 		addr <= addr+1'b1;
// 	else 
// 		addr <= addr;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		cnt_1s <= 24'd0;
    else if(cnt_1s == 32'd119999)
        cnt_1s <= 24'd0;
	else if(cnt_1s < 32'd119999)
		cnt_1s <= cnt_1s +1'd1;
	else
		cnt_1s <= cnt_1s;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		no_flag<= 1'b0;
	else if(cnt_1s == 32'd0)
		no_flag <=1'b1;
	else if(cnt_1s == 32'd95999)
		no_flag <=1'b0;

	else
	no_flag<= no_flag;


endmodule
