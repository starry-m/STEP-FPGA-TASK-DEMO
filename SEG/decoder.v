
module decoder(
		input					rst_n,			//ϵͳ��λ������Ч
		input					rx_data_valid,	//����������Ч����
		input			[7:0]	rx_data_out,	//���յ�������
		output reg	[7:0]	data_en,		//���յ�������
		output reg	[31:0]seg_data
	);

`ifdef HEX_FORMAT //�����define�����HEX_FORMAT
	//����16���Ƹ�ʽ�����յ������ݵ�����ֵ����
	wire [7:0] seg_data_r = rx_data_out;

	//��λ�Ĵ�������Ӧ8λ���������BCD��
	always @ (posedge rx_data_valid or negedge rst_n) begin
		if(!rst_n) 
			seg_data <= 1'b0;
		else 
			seg_data <= {seg_data[23:0],seg_data_r};
	end

	//��λ�Ĵ�������Ӧ8λ�����������ʾʹ��
	always @ (posedge rx_data_valid or negedge rst_n) begin
		if(!rst_n) 
			data_en <= 1'b0;
		else 
			data_en <= {data_en[5:0],2'b11};
	end
`else
	//�����ַ���ʽ�����յ�������Ϊ�ַ�ASCII��ֵ��������ֵ���48
	wire [7:0] seg_data_r = rx_data_out - 8'd48;

	//��λ�Ĵ�������Ӧ8λ���������BCD��
	always @ (posedge rx_data_valid or negedge rst_n) begin
		if(!rst_n) 
			seg_data <= 1'b0;
		else 
			seg_data <= {seg_data[27:0],seg_data_r[3:0]};
	end

	//��λ�Ĵ�������Ӧ8λ�����������ʾʹ��
	always @ (posedge rx_data_valid or negedge rst_n) begin
		if(!rst_n) 
			data_en <= 1'b0;
		else 
			data_en <= {data_en[6:0],1'b1};
	end
`endif

endmodule
