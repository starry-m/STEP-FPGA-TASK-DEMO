// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: tone
// 
// Author: Step
// 
// Description: tone
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module music_to_tone
(
input			[4:0]	choose,
output	reg		[15:0]	cycle
);

//不同按键按下对应得到不同的PWM周期
//已知蜂鸣器某音节对应的蜂鸣器震荡频率为261.6Hz，系统时钟频率为12MHz
//故每个蜂鸣器震荡周期时间等于12M/261.6=45872个系统时钟的周期时间之和
//我们把按键信息译成PWM模块周期cycle对应的值，输出给PWM模块
always@(*) begin
	// case(choose)
    //     5'd0: cycle = 16'd0;//cycle为0，PWM占空比为0，低电平
	// 	5'd1: cycle = 16'd45872;	//L1,
	// 	5'd2: cycle = 16'd40858;	//L2,
	// 	5'd3: cycle = 16'd36408;	//L3,
	// 	5'd4: cycle = 16'd34364;	//L4,
	// 	5'd5: cycle = 16'd30612;	//L5,
	// 	5'd6: cycle = 16'd27273;	//L6,
	// 	5'd7: cycle = 16'd24296;	//L7,
	// 	5'd8: cycle = 16'd22931;	//M1,523Hz
	// 	5'd9: cycle = 16'd20432;	//M2,587Hz
	// 	5'd10: cycle = 16'd18201;	//M3,659Hz
	// 	5'd11: cycle = 16'd17180;	//M4,698Hz
	// 	5'd12: cycle = 16'd15306;	//M5,784Hz
	// 	5'd13: cycle = 16'd13636;	//M6,880Hz
	// 	5'd14: cycle = 16'd12148;	//M7,998Hz
	// 	5'd15: cycle = 16'd11478;	//H1,1046Hz
	// 	5'd16: cycle = 16'd10215;	//H2,1174
    //     5'd17: cycle = 16'd9105;	//H3,1318
	// 	5'd18: cycle = 16'd8596;	//H4,1396
    //     5'd19: cycle = 16'd7654;	//H5,1568
	// 	5'd20: cycle = 16'd6819;	//H6,1760
    //     5'd21: cycle = 16'd6073;	//H7,1976
	// 	default:  cycle = 16'd0;		//cycle为0，PWM占空比为0，低电平
	// endcase
	case(choose)
        5'd0: cycle = 16'd0;//cycle为0，PWM占空比为0，低电平
		5'd1: cycle = 16'd458;	//L1,
		5'd2: cycle = 16'd408;	//L2,
		5'd3: cycle = 16'd364;	//L3,
		5'd4: cycle = 16'd343;	//L4,
		5'd5: cycle = 16'd306;	//L5,
		5'd6: cycle = 16'd272;	//L6,
		5'd7: cycle = 16'd242;	//L7,
		5'd8: cycle = 16'd229;	//M1,523Hz
		5'd9: cycle = 16'd204;	//M2,587Hz
		5'd10: cycle = 16'd182;	//M3,659Hz
		5'd11: cycle = 16'd171;	//M4,698Hz
		5'd12: cycle = 16'd153;	//M5,784Hz
		5'd13: cycle = 16'd136;	//M6,880Hz
		5'd14: cycle = 16'd12;	//M7,998Hz
		5'd15: cycle = 16'd114;	//H1,1046Hz
		5'd16: cycle = 16'd102;	//H2,1174
        5'd17: cycle = 16'd91;	//H3,1318
		5'd18: cycle = 16'd85;	//H4,1396
        5'd19: cycle = 16'd76;	//H5,1568
		5'd20: cycle = 16'd68;	//H6,1760
        5'd21: cycle = 16'd60;	//H7,1976
		default:  cycle = 16'd0;		//cycle为0，PWM占空比为0，低电平
	endcase

end
	
endmodule
