// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: array_keyboard
// 
// Author: Step
// 
// Description: array_keyboard
// 
// Web: www.stepfapga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module array_keyboard #
(
	parameter			CNT_200HZ = 60000
)
(
	input					clk,
	input					rst_n,
	input			[3:0]	col,
	output reg	[3:0]	row,
	output reg	[15:0]key_out,
	output		[15:0]key_pulse
);
	
	localparam			STATE0 = 2'b00;
	localparam			STATE1 = 2'b01;
	localparam			STATE2 = 2'b10;
	localparam			STATE3 = 2'b11;
	
	/*
	��ʹ��4x4���󰴼���ͨ��ɨ�跽��ʵ�֣���������ʹ��״̬��ʵ�֣�����Ϊ4��״̬
	�����е�ĳһ״̬ʱ�����Ӧ��4�������൱�ڶ����������ɰ��������������ڲ���������
	���ڲ���ʱÿ��20ms����һ�Σ���Ӧ����״̬��ÿ��20msѭ��һ�Σ�ÿ��״̬��Ӧ5msʱ��
	�Ծ��󰴼�ʵ��ԭ�����׵ģ���ȥ�˽���󰴼�ʵ��ԭ��
	*/
	
	//������������Ƶʵ��5ms�����ź�clk_200hz,ϵͳʱ��12MHz
	reg	[15:0]	cnt;
	reg				clk_200hz;
	always@(posedge clk or negedge rst_n) begin  //��λʱ������cnt���㣬clk_200hz�ź���ʼ��ƽΪ�͵�ƽ
		if(!rst_n) begin
			cnt <= 16'd0;
			clk_200hz <= 1'b0;
		end else begin
			if(cnt >= ((CNT_200HZ>>1) - 1)) begin  //�����߼�������1λ�൱�ڳ�2
				cnt <= 16'd0;
				clk_200hz <= ~clk_200hz;  //clk_200hz�ź�ȡ��
			end else begin
				cnt <= cnt + 1'b1;
				clk_200hz <= clk_200hz;
			end
		end
	end
	
	reg		[1:0]		c_state;
	//״̬������clk_200hz�ź���4��״̬��ѭ����ÿ��״̬�Ծ��󰴼����нӿڵ�����Ч
	always@(posedge clk_200hz or negedge rst_n) begin
		if(!rst_n) begin
			c_state <= STATE0;
			row <= 4'b1110;
		end else begin
			case(c_state)
				//״̬c_state��ת����Ӧ״̬�¾��󰴼���row���
				STATE0: begin c_state <= STATE1; row <= 4'b1101; end
				STATE1: begin c_state <= STATE2; row <= 4'b1011; end
				STATE2: begin c_state <= STATE3; row <= 4'b0111; end
				STATE3: begin c_state <= STATE0; row <= 4'b1110; end
				default:begin c_state <= STATE0; row <= 4'b1110; end
			endcase
		end
	end
	
	reg	[15:0]	key,key_r;
	//��Ϊÿ��״̬�е�����Ч��ͨ�����нӿڵĵ�ƽ״̬�����õ���Ӧ4��������״̬������ѭ��
	always@(negedge clk_200hz or negedge rst_n) begin
		if(!rst_n) begin
			key_out <= 16'hffff; key_r <= 16'hffff; key <= 16'hffff; 
		end else begin
			case(c_state)
				//�ɼ���ǰ״̬�������ݸ�ֵ����Ӧ�ļĴ���λ
				//�Լ��̲������ݽ����ж����������β����͵�ƽ�ж�Ϊ��������
				STATE0: begin key_out[ 3: 0] <= key_r[ 3: 0]|key[ 3: 0]; key_r[ 3: 0] <= key[ 3: 0]; key[ 3: 0] <= col; end
				STATE1: begin key_out[ 7: 4] <= key_r[ 7: 4]|key[ 7: 4]; key_r[ 7: 4] <= key[ 7: 4]; key[ 7: 4] <= col; end
				STATE2: begin key_out[11: 8] <= key_r[11: 8]|key[11: 8]; key_r[11: 8] <= key[11: 8]; key[11: 8] <= col; end
				STATE3: begin key_out[15:12] <= key_r[15:12]|key[15:12]; key_r[15:12] <= key[15:12]; key[15:12] <= col; end
				default:begin key_out <= 16'hffff; key_r <= 16'hffff; key <= 16'hffff; end
			endcase
		end
	end
	
	reg		[15:0]		key_out_r;
	//Register low_sw_r, lock low_sw to next clk
	always @ ( posedge clk  or  negedge rst_n )
		if (!rst_n) key_out_r <= 16'hffff;
		else  key_out_r <= key_out;   //��ǰһ�̵�ֵ�ӳ�����
	
	//wire	[15:0]		 key_pulse;
	//Detect the negedge of low_sw, generate pulse
	assign key_pulse= key_out_r & ( ~key_out);   //ͨ��ǰ������ʱ�̵�ֵ�ж�
	
endmodule
