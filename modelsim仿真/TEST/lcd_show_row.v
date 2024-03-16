module lcd_show_row (input wire sys_clk,
                     input wire sys_rst_n,
                     input wire wr_done,
                     input wire show_pic_flag,        //显示字符标志信号
                     input wire [8:0] col_pos,
                     input wire [7:0] rom_q,
                     output  [8:0] rom_addr,
                     output wire [8:0] show_pic_data, //传输的命令或者数??
                     output wire show_pic_done,
                     output wire [3:0] register_r,
                     output reg  [3:0] cnt_set_windows,
                     output wire en_write_show_pic);
    
    //****************** Parameter and Internal Signal *******************//
    
    
    parameter SIZE_WIDTH_MAX  = 9'd479;
    parameter SIZE_LENGTH_MAX = 9'd319;
    
    parameter STATE0 = 4'b0_001;
    parameter STATE1 = 4'b0_010;
    parameter STATE2 = 4'b0_100;
    parameter DONE   = 4'b1_000;
    
    //???????????
    reg  [3:0] state;
    assign register_r=state;
    /*wr_done 打一??*/
    reg          the1_wr_done;
    //设置显示窗口
    // reg  [3:0] cnt_set_windows;
    
    //??????STATE1跳转到STATE2的标志信??
    reg          state1_finish_flag;
    
    //等待rom数据读取完成的计数器
    reg  [2:0] cnt_rom_prepare;
    
    //rom输出数据移位后得到的数据temp
    reg  [15:0] temp;
    
    //长度??1标志信号
    reg          length_num_flag;
    
    //长度计数??
    reg  [8:0] cnt_length_num;
    
    //点的颜色计数??
    reg  [9:0] cnt_wr_color_data;
    
    //要传输的命令???????????
    reg  [8:0] data;
    
    //??????STATE2跳转到DONE的标志信??
    wire         state2_finish_flag;
    
    reg [8:0] col_pos_temp;
    always @(*)
        col_pos_temp <= col_pos+1'b1;
    
    //???????????
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) state <= STATE0;
        else
        case (state)
            STATE0: state <= (show_pic_flag) ? STATE1 : STATE0;
            STATE1: state <= (state1_finish_flag) ? STATE2 : STATE1;
            STATE2: state <= (state2_finish_flag) ? DONE : STATE2;
            DONE:   state <= STATE0;
        endcase
        /* 当spi??个字节输出完成，会有??个wr_done脉冲*/
        always @(posedge sys_clk or negedge sys_rst_n)
            if (!sys_rst_n) the1_wr_done   <= 1'b0;
            else if (wr_done) the1_wr_done <= 1'b1;
            else the1_wr_done              <= 1'b0;
    
    //设置显示窗口计数??
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) cnt_set_windows <= 'd0;
        else if (state == STATE1 && the1_wr_done) cnt_set_windows <= cnt_set_windows + 1'b1;
        else cnt_set_windows <= cnt_set_windows;
    
    //??????STATE1跳转到STATE2的标志信??
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) state1_finish_flag <= 1'b0;
        else if (cnt_set_windows == 'd10 && the1_wr_done) state1_finish_flag <= 1'b1;
        else state1_finish_flag <= 1'b0;
        /*前面完成了窗口大小位置的设置,后面完成两个颜色数据的传??*/
    
    always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)  
        cnt_rom_prepare <= 'd0;
    else if(length_num_flag)
        cnt_rom_prepare <= 'd0;
    else if(state == STATE2 && cnt_rom_prepare < 'd5)
        cnt_rom_prepare <= cnt_rom_prepare + 1'b1;
        
    reg en_state2_flag;
    always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)  en_state2_flag<=1'b0;
    else if(state == STATE2) en_state2_flag<=1'b1;
    else if(state == DONE) en_state2_flag<=1'b0;
    else en_state2_flag <= en_state2_flag;


    reg [8:0] rom_data_index;
    assign rom_addr=rom_data_index;
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) rom_data_index <= 0;
        else if (state == STATE2 && the1_wr_done && rom_data_index < SIZE_WIDTH_MAX)  rom_data_index <= rom_data_index+1'b1;
        else  rom_data_index <= rom_data_index;
    
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n)  temp <= 'd0;
        else temp             <= {temp[7:0],rom_q};
    
    //长度??1标志信号
    always@(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n)
            length_num_flag <= 1'b0;
            else if (
            state == STATE2 &&
            rom_data_index == SIZE_WIDTH_MAX &&
            the1_wr_done
            )
            length_num_flag <= 1'b1;
        else
            length_num_flag <= 1'b0;
    
    //要传输的命令???????????
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) data <= 9'h000;
        else if (state == STATE1)
        case (cnt_set_windows)
            0: data       <= 9'h02A;
            1: data       <= {1'b1, 8'h00};
            2: data       <= {1'b1, 8'h00};
            3: data       <= {1'b1, 8'h00};
            4: data       <= {1'b1, 8'hef};  //239
            5: data       <= 9'h02B;
            6: data       <= {1'b1, 7'h00,col_pos[8]};
            7: data       <= {1'b1, col_pos[7:0]};
            8: data       <= {1'b1, 7'h00,col_pos_temp[8]};
            9: data       <= {1'b1, col_pos_temp[7:0]};  //319
            10: data      <= 9'h02C;
            default: data <= 9'h000;
        endcase
        else if (state == STATE2)
        data <= {1'b1,temp[15:8]};
    
    else data <= data;
    
    //??????STATE2跳转到DONE的标志信??
    assign state2_finish_flag = (
    (
    (rom_data_index == SIZE_WIDTH_MAX)
    ) &&
    length_num_flag
    ) ? 1'b1 : 1'b0;
    
    //输出端口
    assign show_pic_data     = data;
    assign en_write_show_pic = (state == STATE1 || en_state2_flag) ? 1'b1 : 1'b0;
    assign show_pic_done     = (state == DONE) ? 1'b1 : 1'b0;
    
    
endmodule
