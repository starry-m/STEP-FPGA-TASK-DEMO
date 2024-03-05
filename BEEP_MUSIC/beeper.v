// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: beeper
// 
// Author: Step
// 
// Description: beeper
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module beeper(
		input			clk,
		input			rst_n,
		input	[15:0]key_out,
		output		beeper
	);

wire [15:0]	cycle;
//��������Ϣ������ڶ�Ӧ������cycleֵ
tone u1(
		.key_in(key_out),
		.cycle(cycle)
);

//���ݲ�ͬ���ڵ�����cycleֵ������Ӧ��PWM�ź�
pwm #(
		.WIDTH(16)			//ensure that 2**WIDTH > cycle
	) u2(
		.clk(clk),
		.rst_n(rst_n),
		.cycle(cycle),		//cycle > duty
		.duty(cycle>>1),	//duty=cycle/2,����50%ռ�ձ�
		.pwm_out(beeper)
);
	
endmodule
