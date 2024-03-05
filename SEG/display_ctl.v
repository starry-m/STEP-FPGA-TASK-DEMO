// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: display_ctl 
// 
// Author: Step
// 
// Description: Real time display with segment led_out of UART�����ڣ�
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module display_ctl (
		input					clk,			//ϵͳʱ�� 12MHz
		input					rst_n,		//ϵͳ��λ������Ч

		input					uart_rx,		//UART��������

		output				seg_rck,		//74HC595��RCK�ܽ�
		output				seg_sck,		//74HC595��SCK�ܽ�
		output				seg_din		//74HC595��SER�ܽ�
	);	

//`define HEX_FORMAT  //��������ʹ��Hex��ʽ����ʱ����HEX_FORMAT�����򲻶���

wire rx_data_valid;
wire [7:0]	rx_data_out;
//Uart_Bus module
uart_bus u1(	
		.clk(clk),							//ϵͳʱ�� 12MHz
		.rst_n(rst_n),						//ϵͳ��λ������Ч
		.uart_rx(uart_rx),				//UART��������
		.rx_data_valid(rx_data_valid),//����������Ч����
		.rx_data_out(rx_data_out)		//���յ�������
	);

wire [7:0] data_en;
wire [31:0] seg_data;
//
decoder u2(
		.rst_n(rst_n),
		.rx_data_valid(rx_data_valid),//����������Ч����
		.rx_data_out(rx_data_out),		//���յ�������
		.data_en(data_en),				//�����������ʾʹ��
		.seg_data(seg_data)				//���������BCD��
	);

//segment_scan display module
segment_scan u3(
		.clk			(clk					),	//ϵͳʱ�� 12MHz
		.rst_n		(rst_n				),	//ϵͳ��λ ����Ч
		.dat_1		(seg_data[31:28]	),	//SEG1 ��ʾ����������
		.dat_2		(seg_data[27:24]	),	//SEG2 ��ʾ����������
		.dat_3		(seg_data[23:20]	),	//SEG3 ��ʾ����������
		.dat_4		(seg_data[19:16]	),	//SEG4 ��ʾ����������
		.dat_5		(seg_data[15:12]	),	//SEG5 ��ʾ����������
		.dat_6		(seg_data[11: 8]	),	//SEG6 ��ʾ����������
		.dat_7		(seg_data[ 7: 4]	),	//SEG7 ��ʾ����������
		.dat_8		(seg_data[ 3: 0]	),	//SEG8 ��ʾ����������
		.dat_en		(data_en				),	//���������λ��ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
		.dot_en		(8'b0000_0000		),	//�����С����λ��ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
		.seg_rck		(seg_rck				),	//74HC595��RCK�ܽ�
		.seg_sck		(seg_sck				),	//74HC595��SCK�ܽ�
		.seg_din		(seg_din				)	//74HC595��SER�ܽ�
	);

endmodule
