
module lcd_show_pic
(
    input       wire            sys_clk             ,
    input       wire            sys_rst_n           ,
    input       wire            wr_done             ,
    input       wire            show_pic_flag       ,   //��ʾ�ַ���־�ź�

	 output       reg     [8:0]  rom_addr,
	 input			 wire    [239:0]   rom_q,

    output      wire    [8:0]   show_pic_data       ,   //����������������
	 output		wire				 show_pic_done,
    output      wire            en_write_show_pic   
);

//������ɫ
parameter   WHITE   = 16'hFFFF,
            BLACK   = 16'h0000,	  
            BLUE    = 16'h001F,  
            BRED    = 16'hF81F,
            GRED 	  = 16'hFFE0,
            GBLUE	  = 16'h07FF,
            RED     = 16'hF800,
            MAGENTA = 16'hF81F,
            GREEN   = 16'h07E0,
            CYAN    = 16'h7FFF,
            YELLOW  = 16'hFFE0,
            BROWN   = 16'hBC40, //��ɫ
            BRRED   = 16'hFC07, //�غ�ɫ
            GRAY    = 16'h8430; //��ɫ

//****************** Parameter and Internal Signal *******************//


parameter   SIZE_WIDTH_MAX = 8'd239;
parameter   SIZE_LENGTH_MAX = 9'd319;

parameter   STATE0 = 4'b0_001;     
parameter   STATE1 = 4'b0_010;
parameter   STATE2 = 4'b0_100;
parameter   DONE   = 4'b1_000;

//״̬ת��
reg     [3:0]   state;

//������ʾ����
reg             the1_wr_done;
reg     [3:0]   cnt_set_windows;

//״̬STATE1��ת��STATE2�ı�־�ź�
reg            state1_finish_flag;

//�ȴ�rom���ݶ�ȡ��ɵļ�����
reg     [2:0]   cnt_rom_prepare;

//rom�ĵ�ַ
//reg     [8:0]  rom_addr;
//wire    [239:0]   rom_q;

//rom���������λ��õ�������temp
reg     [239:0]   temp;

//���ȼ�1��־�ź�
reg             length_num_flag;

//���ȼ�����
reg     [8:0]   cnt_length_num;

//�����ɫ������
reg     [9:0]   cnt_wr_color_data;

//Ҫ����������������
reg     [8:0]   data;

//״̬STATE2��ת��DONE�ı�־�ź�        
wire    state2_finish_flag;

//******************************* Main Code **************************//


//״̬ת��
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        state <= STATE0;
    else
        case(state)
            STATE0 : state <= (show_pic_flag) ? STATE1 : STATE0;
            STATE1 : state <= (state1_finish_flag) ? STATE2 : STATE1;
            STATE2 : state <= (state2_finish_flag) ? DONE : STATE2;
            DONE   : state <= STATE0;
        endcase
//��Ҫ//
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n) 
        the1_wr_done <= 1'b0;
    else if(wr_done)
        the1_wr_done <= 1'b1;
    else
        the1_wr_done <= 1'b0;
        
//������ʾ���ڼ�����
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)  
        cnt_set_windows <= 'd0;
    else if(state == STATE1 && the1_wr_done)
        cnt_set_windows <= cnt_set_windows + 1'b1;

//״̬STATE1��ת��STATE2�ı�־�ź�
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        state1_finish_flag <= 1'b0;
    else if(cnt_set_windows == 'd10 && the1_wr_done)
        state1_finish_flag <= 1'b1;
    else
        state1_finish_flag <= 1'b0;

//�ȴ�rom���ݶ�ȡ��ɵļ�����
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)  
        cnt_rom_prepare <= 'd0;
    else if(length_num_flag)
        cnt_rom_prepare <= 'd0;
    else if(state == STATE2 && cnt_rom_prepare < 'd5)
        cnt_rom_prepare <= cnt_rom_prepare + 1'b1;
        
//rom�ĵ�ַ
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        rom_addr <= 'd0;
    else if(cnt_rom_prepare == 'd1)      
        rom_addr <=  cnt_length_num;

//rom���������λ��õ�������temp
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        temp <= 'd0;
    else if(cnt_rom_prepare == 'd3)
        temp <= rom_q;
    else if(state == STATE2 && the1_wr_done)     
			begin
				if(cnt_wr_color_data[0] == 1)
					temp <= temp >>1;
				else
					temp <= temp;
			end


//���ȼ�1��־�ź�
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        length_num_flag <= 1'b0;
   else if(
            state == STATE2 && 
            cnt_wr_color_data == 10'd479 &&
            the1_wr_done
           )
       length_num_flag <= 1'b1;
    else
       length_num_flag <= 1'b0;
        
//���ȼ�����
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_length_num <= 'd0;
    else if(cnt_length_num < SIZE_LENGTH_MAX && length_num_flag)
        cnt_length_num <= cnt_length_num + 1'b1;

//�����ɫ������
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_wr_color_data <= 'd0;
    else if(cnt_rom_prepare == 'd3 || state == DONE)
        cnt_wr_color_data <= 'd0;
    else if(state == STATE2 && the1_wr_done)
        cnt_wr_color_data <= cnt_wr_color_data + 1'b1;
        
//Ҫ����������������
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        data <= 9'h000;
    else if(state == STATE1)
        case(cnt_set_windows)
            0 : data <= 9'h02A;
            1 : data <= {1'b1,8'h00};
            2 : data <= {1'b1,8'h00};
            3 : data <= {1'b1,8'h00};
            4 : data <= {1'b1,8'hef};//239
            5 : data <= 9'h02B;
            6 : data <= {1'b1,8'h00};
            7 : data <= {1'b1,8'h00};
            8 : data <= {1'b1,8'h01};
            9 : data <= {1'b1,8'h3f};//319
            10: data <= 9'h02C;
            default: data <= 9'h000;
        endcase
    else if(state == STATE2 && ((temp & 8'h01) == 'd0))
        if(cnt_wr_color_data[0] == 1'b0 )
            data <= {1'b1,BLUE[15:8]};
        else
            data <= {1'b1,BLUE[7:0]};
    else if(state == STATE2 && ((temp & 8'h01) == 'd1))
        if(cnt_wr_color_data[0] == 1'b0 )
            data <= {1'b1,RED[15:8]};
        else
            data <= {1'b1,RED[7:0]};
    else
        data <= data;   

//״̬STATE2��ת��DONE�ı�־�ź�        
assign state2_finish_flag = (
                             (
                                (cnt_length_num == SIZE_LENGTH_MAX)         
                             ) &&
                             length_num_flag
                            ) ? 1'b1 : 1'b0;
        
//����˿�
assign show_pic_data = data;
assign en_write_show_pic = (state == STATE1 || cnt_rom_prepare == 'd5) ? 1'b1 : 1'b0;
assign show_pic_done = (state == DONE) ? 1'b1 : 1'b0;
/*
pic_ram pic_ram_u0
(
	.address(rom_addr), 
	.q(rom_q)
);
*/
endmodule
