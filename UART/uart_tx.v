// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: uart_tx
// 
// Author: Step
// 
// Description: The transfer module of uart interface
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module uart_tx(
		input					clk,				//ϵͳʱ�� 12MHz
		input					rst_n,			//ϵͳ��λ������Ч
		
		output	reg		bps_en,			//����ʱ��ʹ��
		input					bps_clk,			//����ʱ������
		
		input					tx_data_valid,	//����������Ч����
		input			[7:0]	tx_data_in,		//Ҫ���͵�����
		output	reg		uart_tx			//UART�������
	);

reg				[3:0]	num;
reg				[9:0]	tx_data_r;	//�ں�����ʼλ��ֹͣλ������
//�����������ݲ���
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		bps_en <= 1'b0;
		tx_data_r <= 10'd0;
	end else if(tx_data_valid && (!bps_en))begin	
		bps_en <= 1'b1;		//����⵽����ʱ��ʹ���źŵ��½��أ�����������ɣ���Ҫ�������ݣ�ʹ�ܷ���ʱ��ʹ���ź�
		tx_data_r <= {1'b1,tx_data_in,1'b0};	
	end else if(num==4'd10) begin	
		bps_en <= 1'b0;		//һ��UART������Ҫ10��ʱ���źţ�Ȼ�����
	end
end

//�����ڹ���״̬��ʱ�����շ���ʱ�ӵĽ��ķ�������
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		num <= 1'b0;
		uart_tx <= 1'b1;
	end else if(bps_en) begin
		if(bps_clk) begin
			num <= num + 1'b1;
			uart_tx <= tx_data_r[num];
		end else if(num>=4'd10) 
			num <= 4'd0;	
	end
end

endmodule
