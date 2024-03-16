

module  lcd_write
(
    input   wire            sys_clk_50MHz       ,
    input   wire            sys_rst_n           ,
    input   wire    [8:0]   data                ,
    input   wire            en_write            ,

    output  reg             wr_done             ,
    output  wire            cs                  ,
    output  wire            dc                  ,
    output  reg             sclk                ,
    output  reg             mosi                
);

//****************** Parameter and Internal Signal *******************//
//����spi��ģʽ���ֱ�Ϊ
//ģʽ0��CPOL = 0, CPHA = 0;
//ģʽ1��CPOL = 0, CPHA = 1;
//ģʽ2��CPOL = 1, CPHA = 0;
//ģʽ3��CPOL = 1, CPHA = 1;
parameter CPOL = 1'b0;  //ʱ�Ӽ���
parameter CPHA = 1'b0;  //ʱ����λ

parameter DELAY_TIME = 3'd4; //����С��3

parameter CNT_SCLK_MAX = 4'd4; //����С��3

parameter STATE0 = 4'b0_001;
parameter STATE1 = 4'b0_010;
parameter STATE2 = 4'b0_100;
parameter DONE   = 4'b1_000;

//----------------------------------------------------------------- 
reg     [3:0]   state;

reg     [4:0]   cnt_delay;

reg     [3:0]   cnt1;

reg     [3:0]   cnt_sclk;

reg             sclk_flag;

reg             state2_finish_flag;

//******************************* Main Code **************************// 
//ʵ��״̬����ת
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        state <= STATE0;
    else
        case(state)
            STATE0 : state <= (en_write) ? STATE1 : STATE0; 
            STATE1 : state <= (cnt_delay == DELAY_TIME) ? STATE2 : STATE1; 
            STATE2 : state <= (state2_finish_flag) ? DONE : STATE2;
            DONE   : state <= STATE0;
        endcase
        
//----------------------------------------------------------------- 
//������cnt_delay�����ӳ�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_delay <= 'd0;
    else if(state ==  DONE)
        cnt_delay <= 'd0;
    else if(state == STATE1 && cnt_delay < DELAY_TIME)
        cnt_delay <= cnt_delay + 1'b1;
    else
        cnt_delay <= 'd0;

//������cnt1�����sclk_flag��ָʾmosi�ĸ��ºͱ��֡�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt1 <= 'd0;
    else if(state == STATE1)
        cnt1 <= 'd0;
    else if(state == STATE2 && cnt_sclk == CNT_SCLK_MAX)
        cnt1 <= cnt1 + 1'b1;
        
//������cnt_sclk����spi��ʱ��       
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_sclk <= 'd0;
    else if(cnt_sclk == CNT_SCLK_MAX)
        cnt_sclk <= 'd0;
    else if(state == STATE2 && cnt_sclk < CNT_SCLK_MAX)
        cnt_sclk <= cnt_sclk + 1'b1;
         
//ʱ��sclk�ı�־�ź�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        sclk_flag <= 1'b0;
    //ʱ����λΪ1ʱ����ǰ���ߣ����豸��ż���زɼ�����
    else if(CPHA == 1'b1 && state == STATE1 && (cnt_delay == DELAY_TIME - 1'b1))
        sclk_flag <= 1'b1;
    else if(cnt_sclk == CNT_SCLK_MAX - 1'b1)
        sclk_flag <= 1'b1;
    else
        sclk_flag <= 1'b0;
        
//״̬STATE2��ת��״̬DONE�ı�־�ź�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        state2_finish_flag <= 1'b0;
    else if(cnt1 == 'd15 && (cnt_sclk == CNT_SCLK_MAX - 1'b1))
        state2_finish_flag <= 1'b1;
    else
        state2_finish_flag <= 1'b0;
        
//-----------------------------------------------------------------           
//sclkʱ���ź�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        sclk <= 1'b0;
    //ʱ�Ӽ���Ϊ1������ʱsclk��״̬Ϊ�ߵ�ƽ
    else if(CPOL == 1'b1 && state == STATE0)
        sclk <= 1'b1;
    //ʱ�Ӽ���Ϊ0������ʱsclk��״̬Ϊ�׵�ƽ
    else if(CPOL == 1'b0 && state == STATE0)
        sclk <= 1'b0;
    else if(sclk_flag)  //ֻҪslck_flag���߾���sclk��ƽ��ת
        sclk <= ~sclk;
    else
        sclk <= sclk;

//mosi��SPI����д�����ź�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        mosi <= 1'b0;
    else if(state == STATE0)
        mosi <= 1'b0;
    else if(state == STATE1 && cnt_delay == CNT_SCLK_MAX)
        mosi <= data[7];
    else if(state == STATE2 && sclk_flag)
        case(cnt1)
            1 : mosi <= data[6];
            3 : mosi <= data[5];
            5 : mosi <= data[4];
            7 : mosi <= data[3];
            9 : mosi <= data[2];
            11: mosi <= data[1];
            13: mosi <= data[0];
            15: mosi <= 1'b0;
            default: mosi <= mosi;
        endcase
    else 
        mosi <= mosi;

//wr_done������ɱ�־�ź�
always@(posedge sys_clk_50MHz or negedge sys_rst_n)
    if(!sys_rst_n)
        wr_done <= 1'b0;
    else if(state == DONE)
        wr_done <= 1'b1;
    else
        wr_done <= 1'b0;

//csƬѡ�źţ��͵�ƽ��Ч
assign cs = (state == STATE2) ? 1'b0 : 1'b1;

//dcҺ�����Ĵ���/����ѡ���źţ��͵�ƽ���Ĵ������ߵ�ƽ������
//���յ�data�����λ����dc��״̬
assign dc = data[8]; 

endmodule