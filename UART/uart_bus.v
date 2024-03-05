// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: uart_bus
// 
// Author: Step
// 
// Description: The module for uart communication
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module uart_bus #(
		parameter				BPS_PARA = 1250 	//12MHzʱ��ʱ����1250��Ӧ9600�Ĳ�����
	)(
		input					clk,			//ϵͳʱ�� 12MHz
		input					rst_n,			//ϵͳ��λ������Ч

		input					uart_rx,		//UART��������
		output				rx_data_valid,	//����������Ч����
		output	[7:0]		rx_data_out		//���յ�������

		//input					tx_data_valid,	//����������Ч����
		//input			[7:0]	tx_data_in,		//Ҫ���͵�����
		//output				uart_tx			//UART�������
);	
	
/////////////////////////////////UART���չ���ģ������////////////////////////////////////

wire					bps_en_rx,bps_clk_rx;

//UART���ղ�����ʱ�ӿ���ģ�� ����
baud #(
		.BPS_PARA(BPS_PARA)
	)baud_rx(	
		.clk(clk),				//ϵͳʱ�� 12MHz
		.rst_n(rst_n),			//ϵͳ��λ������Ч
		.bps_en(bps_en_rx),	//����ʱ��ʹ��
		.bps_clk(bps_clk_rx)	//����ʱ�����
	);

//UART��������ģ�� ����
uart_rx uart_rx_uut(
		.clk(clk),							//ϵͳʱ�� 12MHz
		.rst_n(rst_n),						//ϵͳ��λ������Ч
		
		.bps_en(bps_en_rx),				//����ʱ��ʹ��
		.bps_clk(bps_clk_rx),			//����ʱ������
		
		.uart_rx(uart_rx),				//UART��������
		.rx_data_valid(rx_data_valid),//����������Ч����
		.rx_data_out(rx_data_out)		//���յ�������
	);
	
/////////////////////////////////UART���͹���ģ������////////////////////////////////////
/*
wire					bps_en_tx,bps_clk_tx;

//UART���Ͳ�����ʱ�ӿ���ģ�� ����
baud # (
		.BPS_PARA				(BPS_PARA		)
	) baud_tx(
		.clk(clk),				//ϵͳʱ�� 12MHz
		.rst_n(rst_n),			//ϵͳ��λ������Ч
		.bps_en(bps_en_tx),	//����ʱ��ʹ��
		.bps_clk(bps_clk_tx)	//����ʱ�����
	);

//UART��������ģ�� ����
uart_tx uart_tx_uut(
		.clk(clk),							//ϵͳʱ�� 12MHz
		.rst_n(rst_n),						//ϵͳ��λ������Ч
		
		.bps_en(bps_en_tx),				//����ʱ��ʹ��
		.bps_clk(bps_clk_tx),			//����ʱ������
		
		.tx_data_valid(tx_data_valid),//����������Ч����
		.tx_data_in(tx_data_in),		//Ҫ���͵�����
		.uart_tx(uart_tx)					//UART�������
	);
*/
endmodule
