// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: uart_rx
// 
// Author: Step
// 
// Description: The receive module of uart interface
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module uart_rx(
		input					clk,			//ϵͳʱ�� 12MHz
		input					rst_n,			//ϵͳ��λ������Ч
		
		output	reg		bps_en,			//����ʱ��ʹ��
		input					bps_clk,		//����ʱ������
		
		input					uart_rx,		//UART��������
		output	reg		rx_data_valid,	//����������Ч����
		output	reg		[7:0]	rx_data_out		//���յ�������
	);	

reg	uart_rx0,uart_rx1,uart_rx2;	
//�༶��ʱ����ȥ������̬
always @ (posedge clk) begin
	uart_rx0 <= uart_rx;
	uart_rx1 <= uart_rx0;
	uart_rx2 <= uart_rx1;
end

//���UART���������źŵ��½���
wire	neg_uart_rx = uart_rx2 & ~uart_rx1;	
		
reg				[3:0]	num;			
//����ʱ��ʹ���źŵĿ���
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		bps_en <= 1'b0;
	else if(neg_uart_rx && (!bps_en))	//������״̬��bps_enΪ�͵�ƽ��ʱ��⵽UART�����ź��½��أ����빤��״̬��bps_enΪ�ߵ�ƽ��������ʱ��ģ���������ʱ��
		bps_en <= 1'b1;		
	else if(num==4'd9)		            //�����һ��UART���ղ������˳�����״̬���ָ�����״̬
		bps_en <= 1'b0;			
end

reg				[7:0]	rx_data;
//�����ڹ���״̬��ʱ�����ս���ʱ�ӵĽ��Ļ�ȡ����
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		num <= 4'd0;
		rx_data <= 8'd0;
	end else if(bps_en) begin	
		if(bps_clk) begin			
			num <= num + 1'b1;
			if(num<=4'd8) rx_data[num-1] <= uart_rx1; //�Ƚ��ܵ�λ�ٽ��ո�λ��8λ��Ч����
		end else if(num == 4'd9) begin		          //���һ��UART���ղ����󣬽���ȡ���������
			num <= 4'd0;				
		end
	end else begin
		num <= 4'd0;
	end
end

//�����յ����������ͬʱ���������Ч�źŲ�������
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rx_data_out <= 8'd0;
		rx_data_valid <= 1'b0;
	end else if(num == 4'd9) begin	
		rx_data_out <= rx_data;
		rx_data_valid <= 1'b1;
	end else begin
		rx_data_out <= rx_data_out;
		rx_data_valid <= 1'b0;
	end
end

endmodule
