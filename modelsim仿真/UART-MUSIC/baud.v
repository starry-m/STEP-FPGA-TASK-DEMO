// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: baud
// 
// Author: Step
// 
// Description: Beat for uart transfer and receive baud rate
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module baud # (
		parameter				BPS_PARA = 1250 //12MHzʱ��ʱ����1250��Ӧ9600�Ĳ�����
	)(
		input					clk,			//ϵͳʱ��
		input					rst_n,		//ϵͳ��λ������Ч
		input					bps_en,		//���ջ���ʱ��ʹ��
		output	reg		bps_clk		//���ջ���ʱ�����
	);	

reg				[12:0]	cnt;
//�������������㲨����ʱ��Ҫ��
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt <= 1'b0;
	else if((cnt >= BPS_PARA-1)||(!bps_en)) //��ʱ���źŲ�ʹ�ܣ�bps_enΪ�͵�ƽ��ʱ�����������㲢ֹͣ����
		cnt <= 1'b0;	                    //��ʱ���ź�ʹ��ʱ����������ϵͳʱ�Ӽ���������ΪBPS_PARA��ϵͳʱ������
	else 
		cnt <= cnt + 1'b1;
end
	
//������Ӧ�����ʵ�ʱ�ӽ��ģ�����ģ�齫�Դ˽��Ľ���UART���ݽ���
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		bps_clk <= 1'b0;
	else if(cnt == (BPS_PARA>>1)) //����һλ���ڳ���2����ֵBPS_PARAΪ���ݸ���㣬��ֵ�����ȶ�����������
		bps_clk <= 1'b1;	
	else 
		bps_clk <= 1'b0;
end

endmodule