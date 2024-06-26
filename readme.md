# 小脚丫FPGA任务完成记录

[平台链接](https://www.eetree.cn/platform/2523)
[任务链接](https://www.eetree.cn/vendorProject/preview/397)

计划完成 UART传输图片和音乐进行显示和播放


2024.3.15完成


# step-FPGA:UART传输图片和音乐进行显示和播放

## 一、任务要求

*  实现利用串行接口与计算机的通信，将电脑上的多个图片和相应的音乐通过PC上的串行接口发送给FPGA，FPGA收到数据以后将图片在TFTLCD上显示出来，将音乐通过蜂鸣器进行播放。

* 使用扩展底板上的按键切换图片和音乐。

## 二、设计思路

我们需要使用小脚丫扩展板上的资源来完成任务要求。其中，需要用到的硬件：
**1.串口：数据收发** 
**2.ST7789 LCD 320X240：图片显示**
**3.蜂鸣器：音乐播放**
**4.矩阵键盘：切换图片和音乐**

我们可以将任务的要求拆分成一个个小要求，然后分别完成，再组合，即可完成。
过程处理的流程图如下：
![](./pic/流程图.png)
图中我是一行一行显示图片的原因是FPGA资源限制，无法提供足够大的RAM，我曾尝试开辟10行的图片缓存，**240x2x10bit**大小的RAM，结果Diamond直接综合半天，然后布线失败。
所以任务的完成是靠上位机和FPGA板子合作完成的。而音乐，我是在传输图片前将音乐的频谱发给FPGA，存到RAM中。后面再通过按键选择播放。


## 三、实现过程
我使用的本地的IDE Diamond，没选择用web IDE。但是Dimond的编辑器用起来不是很舒服，所以用的vs code编辑、Diamond综合、modelsim仿真。上位机用的python脚本。
LCD ST7789的使用流程为：初始化、指定像素显示位置和大小、传输对应大小像素数据。细节原理不再赘述，可自行学习。串口、PWM、矩阵按键原理一样可以自行学习，这里只对上层处理进行报告。

### 1、LCD逐行显示

小脚丫FPGA提供的例程里面关于LCD的只有从ROM中读取1位表示1个像素显示，完成整个屏幕显示，因此第一步我们只需要在原来的基础上把整个屏幕显示换成从rom中读取一行的数据一行一行的显示（一共320行）。测试完成后，把具体显示哪一行由模块外部决定。具体代码实现如下
```verilog
lcd_show_rom.v
module lcd_show_row (input wire sys_clk,
                     input wire sys_rst_n,
                     input wire wr_done,
                     input wire show_pic_flag,        
                     input wire [8:0] col_pos,
                     input wire [7:0] rom_q,
                     output wire [8:0] rom_addr,
                     output wire [8:0] show_pic_data, 
                     output wire show_pic_done,
                     output wire en_write_show_pic);
    
    
    //****************** 
    Parameter and Internal Signal *******************//
    
    
    parameter SIZE_WIDTH_MAX  = 9'd479;
    parameter SIZE_LENGTH_MAX = 9'd319;
    
    parameter STATE0 = 4'b0_001;
    parameter STATE1 = 4'b0_010;
    parameter STATE2 = 4'b0_100;
    parameter DONE   = 4'b1_000;
    
    //状态机
    reg  [3:0] state;
    
    /*wr_done 打一拍*/
    reg          the1_wr_done;
    //设置显示窗口
    reg  [3:0] cnt_set_windows;
    
    //??????STATE1跳转到STATE2的标志
    reg          state1_finish_flag;
    
    //等待rom数据读取完成的计数器
    reg  [2:0] cnt_rom_prepare;
    
    //rom输出数据移位后得到的数据temp
    reg  [15:0] temp;
    
    //长度为1标志信号
    reg          length_num_flag;
    
    //长度计数
    reg  [8:0] cnt_length_num;
    
    //点的颜色计数
    reg  [9:0] cnt_wr_color_data;
    
    //要传输的命令
    reg  [8:0] data;
    
    //从STATE2跳转到DONE的标志
    wire         state2_finish_flag;
    
    reg [8:0] col_pos_temp;
    always @(*)
        col_pos_temp <= col_pos+1'b1;
    
    //状态机实现
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) state <= STATE0;
        else
        case (state)
            STATE0: state <= (show_pic_flag) ? STATE1 : STATE0;
            STATE1: state <= (state1_finish_flag) ? STATE2 : STATE1;
            STATE2: state <= (state2_finish_flag) ? DONE : STATE2;
            DONE:   state <= STATE0;
        endcase
        /* spi写完一个字节脉冲，打一拍*/
        always @(posedge sys_clk or negedge sys_rst_n)
            if (!sys_rst_n) the1_wr_done   <= 1'b0;
            else if (wr_done) the1_wr_done <= 1'b1;
            else the1_wr_done              <= 1'b0;
    
    //设置显示窗口计数
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) cnt_set_windows <= 'd0;
        else if (state == STATE1 && the1_wr_done) cnt_set_windows < = cnt_set_windows + 1'b1;
        else cnt_set_windows <= cnt_set_windows;
    
    //STATE1跳转到STATE2的标志信
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) state1_finish_flag <= 1'b0;
        else if (cnt_set_windows == 'd10 && the1_wr_done) state1_finish_flag < = 1'b1;
        else state1_finish_flag <= 1'b0;
        /*前面完成了窗口大小位置的设置,后面完成两个颜色数据的传输*/
    
    reg en_state2_flag;
    always@(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n)  en_state2_flag <= 1'b0;
        else if (state == STATE2) en_state2_flag< = 1'b1;
        else if (state == DONE) en_state2_flag< = 1'b0;
        else en_state2_flag <= en_state2_flag;
    
    reg [8:0] rom_data_index;
    assign rom_addr = rom_data_index;
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n) rom_data_index <= 0;
        else if (state == STATE0)  rom_data_index < = 0;
        else if (state == STATE2 && the1_wr_done && rom_data_index < SIZE_WIDTH_MAX)  rom_data_index < = rom_data_index+1'b1;
        else  rom_data_index <= rom_data_index;
    
    always @(posedge sys_clk or negedge sys_rst_n)
        if (!sys_rst_n)  temp <= 16'd0;
        else temp             <= {temp[7:0],rom_q};
    
    //长度为1标志信号
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
    
    //the cmd and data which whill transmit
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
            // 6: data    <= {1'b1, 8'h00};
            // 7: data    <= {1'b1, 8'h05};
            // 8: data    <= {1'b1, 8'h00};
            // 9: data    <= {1'b1, 8'h06};  //319
            10: data      <= 9'h02C;
            default: data <= 9'h000;
        endcase
        else if (state == STATE2)
        data <= {1'b1,temp[15:8]};
    
    else data <= data;

    //STATE2跳转到DONE的标志
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

```
这里对行显示在modelsim下做了仿真（提供的历程中现成的模块不再仿真）
testbench如下：
``` verilog

`timescale 1ns / 100ps
module lcd_bar_tb;
parameter CLK_PERIOD = 2; 
 
reg clk;
initial clk = 1'b0;
always #(CLK_PERIOD/2) clk = ~clk;

reg rst_n;  //active low
wire    [8:0]   data;
// wire    en_write;
wire    wr_done;
wire    lcd_cs,lcd_dc,lcd_sclk,lcd_mosi;
// wire    [8:0]   init_data;
// wire            en_write_init;
// wire            init_done;
// wire    [8:0]   show_pic_data     ;
wire    show_pic_done;
wire    en_write_show_pic;
// wire    [8:0] col_pos;
wire     [8:0]  rom_addr;
wire     [7:0]  rom_q;
reg  show_pic_flag;

wire [3:0]  register_r;
// reg [8:0] write_test_data;
// integer          i;  
// reg [7:0] mem[0:8];
initial begin
    show_pic_flag=0;
    rst_n = 1'b0;
    // write_test_data=9'h123;
    #4;
    show_pic_flag=0;
    rst_n = 1'b1;
    #1000;
    show_pic_flag=1;
    // write_test_data=9'h23;
end

lcd_ram u_lcd_ram
(
    .rom_q  (rom_q),
    .rom_addr(rom_addr)
);

lcd_write  lcd_write_inst
(
    .sys_clk_50MHz(clk	  ),
    .sys_rst_n    (rst_n  		  ),
    .data         (data         ),
    .en_write     ( en_write_show_pic ),//en_write_show_pic
                                
    .wr_done      (wr_done      ),
    .cs           (lcd_cs       ),
    .dc           (lcd_dc       ),
    .sclk         (lcd_sclk     ),
    .mosi         (lcd_mosi     )
);
wire  [3:0] cnt_set_windows;
lcd_show_row u_lcd_show_row
(
    .sys_clk			(clk    ),
    .sys_rst_n        	(rst_n        ),
    .wr_done          	(wr_done      ),
    .show_pic_flag    	(show_pic_flag), 
	.col_pos            (9'd100),//col_pos
    .rom_addr	 		(rom_addr), 
	.rom_q				(rom_q),
	.show_pic_data    	(data     ),   
    .show_pic_done      (show_pic_done),
    .register_r (register_r),
    .cnt_set_windows (cnt_set_windows),
    .en_write_show_pic  (en_write_show_pic )  
);


endmodule
```
仿真波形图
![](./pic/行显示仿真.png)

### 2、串口数据存入显示RAM
这里因为例程已经有了串口的输入输出驱动，我们只需要关注1位的有效脉冲和8位的数据。只需要在rx_data_valid为1时，存入数据，并计数。到收到一行的480个数据，停止计数。向外表示数据已存完，并等待LCD显示完成，则向上位机发送字符A表示已完成显示，可以发下一行了。这里写了一个简单的双口RAM，加入写使能信号，当写入时，无法读出数据。反之，读取时，不能写入。
``` verilog
`timescale 1 ns / 100 ps
//240*16*20
//240*16 = 480*8
//SystemVerilog and Verilog Formatter
//row_ram.v
module row_ram #(parameter DATA_WDTH = 4'd8,    //
                      parameter COL = 480,           //RAM
                      parameter COL_BITS = 9)
                     (input clk,                     //
                      input [COL_BITS-1:0] addra,    //
                      input [DATA_WDTH-1:0] dina,    //
                      input W_EN, 
                      input Choice,
                      input [COL_BITS-1:0] addrb,    //
                      output reg [DATA_WDTH-1:0] doutb);

reg [DATA_WDTH-1:0] mem[0:COL-1];  
always @(posedge clk) begin
    if(W_EN)
        mem[addra] <= dina;
    else
        doutb <= mem[addrb];
end


endmodule

```
整个流程还是比较清晰的，需要注意的就是数据存完后的输出脉冲以及读取完成的脉冲信号一些处理。具体代码实现如下
``` verilog
/*
 1+8+1=10
 9600 BIT/S really=7680=7.6K bit/s
 
 SYS_CLK =48M;
 SPI_SCLK=48/10=4.8m; BIT/S
 */
module uart_to_ram (input wire clk_12m,
                    input wire clk,
                    input wire rst_n,
                    input	wire				rx_data_valid,
                    input	wire		[7:0]	rx_data_out,
                    input wire [8:0] addr_out_index,
                    input	wire show_row_done,
                    output	reg				tx_data_valid,
                    output	reg		[7:0]	tx_data_out,
                    output wire [7:0] out_data,
                    output reg [8:0] col_pos,
                    output reg W_EN,
                    output reg row_finished_flag);
    
    //采用16进制格式，接收到的数据等于数值
    parameter  PIC_SIZE      = 18'd153599;
    parameter SIZE_WIDTH_MAX = 9'd479;
    wire [7:0] rx_data_temp  = rx_data_out;
    reg [17:0]  rx_data_index;
    reg [8:0] addr_in_index;
    wire W_EN_temp = W_EN;
    reg [8:0]  length_index;
    
    reg show_row_done_flag;
    reg show_row_done_flag2;
    //移位寄存
    always @ (posedge rx_data_valid or negedge rst_n) begin
        if (!rst_n)
            rx_data_index <= 9'd0;
        else if (rx_data_index == PIC_SIZE)
        begin
            rx_data_index <= 18'd0;
        end
            
        else
            rx_data_index <= rx_data_index + 18'd1;
    end
    
    always @ (posedge clk_12m or negedge rst_n) begin
        if (!rst_n)
            length_index <= 9'd0;
        else if (length_index == 9'd480)
            length_index <= 9'd0;
        else if (rx_data_valid == 1'b1)
            length_index <= length_index + 9'd1;
        else
            length_index <= length_index ;
    end
    
    
    always @ (posedge clk_12m or negedge rst_n)
        if (!rst_n)  begin
            addr_in_index <= 9'd0;
            W_EN          <= 1'b0;
        end
        else if (show_row_done_flag)
            addr_in_index <= 9'd0;
        else if (addr_in_index == SIZE_WIDTH_MAX) begin
            W_EN <= 1'b0;
        end
        else if (addr_in_index < SIZE_WIDTH_MAX && rx_data_valid)
        begin
            addr_in_index <= addr_in_index + 9'd1;
            W_EN          <= 1'b1;
        end
        else begin
            addr_in_index <= addr_in_index;
            W_EN          <= W_EN;
        end
    always @ (posedge clk or negedge rst_n)
        if (!rst_n)  begin
            row_finished_flag <= 1'b0;
        end
        else if (length_index == 9'd480)
        begin
            row_finished_flag <= 1'b1;
        end
        else
        begin
            
            row_finished_flag <= 1'b0;
        end
    
    always @ (posedge clk or negedge rst_n)
        if (!rst_n)  begin
            col_pos            <= 9'd0;
            show_row_done_flag <= 1'd0; 
        end
    
        else if (col_pos == 9'd320)
        col_pos <= 0;
        else if (show_row_done)
        begin
        col_pos <= col_pos + 9'd1;
        
        show_row_done_flag <= 1'd1;
        end
        else if (show_row_done_flag2)
        show_row_done_flag <= 1'd0;
        else
        begin
        col_pos            <= col_pos;
        show_row_done_flag <= show_row_done_flag;
        end
    
    always @ (posedge clk_12m or negedge rst_n)
        if (!rst_n)  begin
            tx_data_out         <= 8'd0;
            tx_data_valid       <= 1'b0;
            show_row_done_flag2 <= 1'b0;
        end
        else if (show_row_done_flag == 1'b1)
        begin
            tx_data_valid       <= 1'b1;
            tx_data_out         <= 8'd65;
            show_row_done_flag2 <= 1'b1;
        end
        else
        begin
            tx_data_valid       <= 1'b0;
            show_row_done_flag2 <= 1'b0;
        end
    
    row_ram u_row_ram
    (.clk(clk),                     //
    .addra(addr_in_index),    //
    .dina(rx_data_temp),    //
    .W_EN(W_EN),
    .Choice(),
    .addrb(addr_out_index),    //
    .doutb(out_data)
    );
endmodule

```
仿真可以使用task模拟串口接收,testbench如下：
``` verilog

/*
 1+8+1=10
 9600 BIT/S really=7680=7.6M bit/s
 
 SYS_CLK =48M;
 SPI_SCLK=48/10=4.8m; BIT/S
 
 */
 `timescale 1ns / 100ps
module uart_to_ram;

parameter CLK_PERIOD = 8; 
 
reg clk;
reg clk_12m;
initial clk = 1'b0;
initial clk_12m = 1'b0;
always #(CLK_PERIOD/8) clk = ~clk;

always #(CLK_PERIOD/2) clk_12m = ~clk_12m;
reg rst_n;  //active low
initial begin
    rst_n = 1'b0;
    // write_test_data=9'h123;
    #4;
    rst_n = 1'b1;
    // write_test_data=9'h23;
end  
wire rx_data_valid;
wire		[7:0]	rx_data_out;
reg [8:0] addr_out_index;
reg show_row_done;
reg				tx_data_valid;
reg		[7:0]	tx_data_out;
wire [7:0] out_data;
reg [8:0] col_pos;
reg W_EN;
reg row_finished_flag;
reg show_row_done_flag;
reg show_row_done_flag2;
//采用16进制格式，接收到的数据等于数值本
parameter  PIC_SIZE      = 9'd153599;
parameter SIZE_WIDTH_MAX = 9'd479;
wire [7:0] rx_data_temp  = rx_data_out;
reg [17:0]  rx_data_index;
reg [8:0]  length_index;
reg [8:0] addr_in_index;
// reg W_EN_temp=W_EN;
reg               uart_rx;
wire              uart_tx;
initial uart_rx=1'b1;
initial show_row_done=1'b0;
initial addr_out_index=8'd0;


uart_bus u1(	
		.clk(clk_12m),							//系统时钟 12MHz
		.rst_n(rst_n),						//系统复位，低有效
		.uart_rx(uart_rx),				//UART接收输入
		.rx_data_valid(rx_data_valid),//接收数据有效脉冲
		.rx_data_out(rx_data_out),		//接收到的数据

        .tx_data_valid(tx_data_valid),	//发送数据有效脉
		.tx_data_in(tx_data_out),		//要发送的数据
		.uart_tx(uart_tx)			//UART发送输
	);


initial begin
	#200;
	rx_byte(); //调用任务rx_byte

    #50;
    show_row_done=1'b1;
    #2;
    show_row_done=1'b0;
    #8;
    rx_byte();
    end
 
task rx_byte();
	integer j;
	for(j=0;j<480;j=j+1)
    begin
		rx_bit(j);  //调用8次rx_bit任务，分别发送0-7
        #(20);
	end
endtask
 
task rx_bit(
	input [7:0] data
);
	integer i;
	for(i=0;i<10;i=i+1)begin
		case(i)
			'd0: uart_rx=1'b0;	//发送起始位
			'd1: uart_rx=data[0];
			'd2: uart_rx=data[1];
			'd3: uart_rx=data[2];
			'd4: uart_rx=data[3];
			'd5: uart_rx=data[4];
			'd6: uart_rx=data[5];
			'd7: uart_rx=data[6];
			'd8: uart_rx=data[7];
			'd9: uart_rx=1'b1;	//发送停止位
			default uart_rx=1'b1;
		endcase
	    #(10*8);
	end
endtask
//移位寄存
always @ (posedge rx_data_valid or negedge rst_n) begin
    if (!rst_n)
        rx_data_index <= 9'd0;
    else if (rx_data_index == PIC_SIZE)
    begin
        rx_data_index <= 18'd0;
    end
        
    else
        rx_data_index <= rx_data_index + 18'd1;
end

always @ (posedge clk_12m or negedge rst_n) begin
    if (!rst_n)
        length_index <= 9'd0;
    else if (length_index == 9'd480)
        length_index <= 9'd0;
    else if (rx_data_valid == 1'b1)
        length_index <= length_index + 9'd1;
    else
        length_index <= length_index ;
end


always @ (posedge clk_12m or negedge rst_n)
    if (!rst_n)  begin
        addr_in_index <= 9'd0;
        W_EN          <= 1'b0;
    end
    else if (show_row_done_flag)
    addr_in_index <= 9'd0;
    else if (addr_in_index == SIZE_WIDTH_MAX)
    begin
        W_EN             <= 1'b0;
        
    end

    else if (addr_in_index < SIZE_WIDTH_MAX && rx_data_valid)
    begin
    addr_in_index <= addr_in_index + 9'd1;
    W_EN          <= 1'b1;
    end
    else
        begin
        addr_in_index  <=  addr_in_index;
        W_EN          <=  W_EN;	
    end
always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
        row_finished_flag <= 1'b0;
    end
    else if (length_index == 9'd480)
    begin
        row_finished_flag <= 1'b1;
    end
    else
    begin
        
        row_finished_flag <= 1'b0;
    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
        col_pos            <= 9'd0;
        show_row_done_flag <= 1'd0;
    end
    else if (col_pos == 9'd320)
    col_pos <= 0;
    else if (show_row_done)
    begin
    col_pos            <= col_pos + 9'd1;

    show_row_done_flag <= 1'd1;
    end
    else if (show_row_done_flag2)
    show_row_done_flag <= 1'd0;
    else
    begin
    col_pos            <= col_pos;
    show_row_done_flag <= show_row_done_flag;
    end

always @ (posedge clk_12m or negedge rst_n)
    if (!rst_n)  begin
        tx_data_out         <= 8'd0;
        tx_data_valid       <= 1'b0;
        show_row_done_flag2 <= 1'b0;
    end
    else if (show_row_done_flag == 1'b1)
    begin
        tx_data_valid       <= 1'b1;
        tx_data_out         <= 8'd65;
        show_row_done_flag2 <= 1'b1;
    end
    else
    begin
        tx_data_valid       <= 1'b0;
        show_row_done_flag2 <= 1'b0;
    end
    
    row_ram u_row_ram
    (.clk(clk),                     //
    .addra(addr_in_index),    //
    .dina(rx_data_temp),    //
    .W_EN(W_EN),
    .Choice(),
    .addrb(addr_out_index),    //
    .doutb(out_data)
    );
endmodule
```
仿真波形图如下：
![](./pic/串口RAM.png)
收到480个数据后，输出接收完成信号。
### 3、音乐播放
例程中有按下矩阵键盘，蜂鸣器输出不同音调的实现。这里先了解下音乐关于音调的基础知识。
[FPGA之蜂鸣器播放音乐《花海》](https://blog.csdn.net/qq_52450571/article/details/125607697)
[基于 FPGA 使用 Verilog 实现蜂鸣器响动的代码及原理讲解](https://blog.csdn.net/ssj925319/article/details/118726264)
我看的这两个博客，主要是不同的音调的发声频率不同，我们需要根据音乐的音谱让蜂鸣器输出对应的音调。
``` verilog
always@(*) begin
	case(choose)
        5'd0: cycle = 16'd0;//cycle为0，PWM占空比为0，低电平
		5'd1: cycle = 16'd45872;	//L1,
		5'd2: cycle = 16'd40858;	//L2,
		5'd3: cycle = 16'd36408;	//L3,
		5'd4: cycle = 16'd34364;	//L4,
		5'd5: cycle = 16'd30612;	//L5,
		5'd6: cycle = 16'd27273;	//L6,
		5'd7: cycle = 16'd24296;	//L7,
		5'd8: cycle = 16'd22931;	//M1,523Hz
		5'd9: cycle = 16'd20432;	//M2,587Hz
		5'd10: cycle = 16'd18201;	//M3,659Hz
		5'd11: cycle = 16'd17180;	//M4,698Hz
		5'd12: cycle = 16'd15306;	//M5,784Hz
		5'd13: cycle = 16'd13636;	//M6,880Hz
		5'd14: cycle = 16'd12148;	//M7,998Hz
		5'd15: cycle = 16'd11478;	//H1,1046Hz
		5'd16: cycle = 16'd10215;	//H2,1174Hz
        5'd17: cycle = 16'd9105;	//H3,1318Hz
		5'd18: cycle = 16'd8596;	//H4,1396Hz
        5'd19: cycle = 16'd7654;	//H5,1568Hz
		5'd20: cycle = 16'd6819;	//H6,1760Hz
        5'd21: cycle = 16'd6073;	//H7,1976Hz
		default:  cycle = 16'd0;		//cycle为0，PWM占空比为0，低电平
	endcase
```
此外，想我们真实的音乐，他的音调不是连续的，中间会有停顿，因此我按照博客的做法，让1s中的前五分之四播放，后五分之一不播放。我整体实现只存了小星星和两只老虎这两首歌，因此RAM用的并不大，通过songs_choose选了播放哪一首。
具体代码实现如下：
``` verilog
module electric_piano(
		input				clk,			//system clock
		input				rst_n,		//system reset

		output reg  [7:0]	addr,
		input    [4:0]	 data,
		input 	songs_choose,
		
		output			beeper
	);  

wire [15:0]	cycle;
reg	 [4:0]	note_c;
// reg  [7:0]	addr;
// wire  [4:0]	data;
reg no_flag;
reg [23:0]cnt_1s;

music_to_tone u2(
		.choose(note_c),
		.cycle(cycle)
);

//根据不同音节的周期cycle值产生对应的PWM信号
pwm #(
		.WIDTH(16)			//ensure that 2**WIDTH > cycle
	) u3(
		.clk(clk),
		.rst_n(rst_n),
		.cycle(cycle),		//cycle > duty
		.duty(cycle>>1),	//duty=cycle/2,产生50%占空比
		.pwm_out(beeper)
);

// music_rom u4(
// .address(addr),
// .data(data)
// );
//songs_choose 
reg [1:0]songs_temp; 
always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		songs_temp <=0;
	else if(songs_temp[0] !=songs_choose)
		songs_temp <= {songs_temp[0],songs_choose};
	else
		songs_temp <=songs_temp ;
always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		note_c <= 5'd0;
	else if(no_flag)
		note_c <= data;
	else if(no_flag == 1'd0)
		note_c <= 5'd0;
	else 
		note_c <= note_c;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		addr <= 8'b0;
	else if(songs_temp[0] != songs_choose)
		addr <= songs_choose ? 8'd48 : 8'b0;

	else if(addr == 8'd47 && !songs_choose&& cnt_1s == 32'd9599999) 
		addr <= 8'b0;//0-47
	
	else if(addr == 8'd83 && songs_choose&& cnt_1s == 32'd9599999) 
		addr <= 8'd48;//48-83

	else if(cnt_1s == 32'd9599999) 
		addr <= addr+1'b1;
	else 
		addr  <= addr;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		cnt_1s <= 24'd0;
	else if(cnt_1s == 32'd11999999)
        cnt_1s <= 24'd0;
	
	else if(cnt_1s < 32'd11999999)
		cnt_1s <= cnt_1s +1'd1;
	else
		cnt_1s <= cnt_1s;

always @(posedge clk or negedge rst_n)
	if(!rst_n) 
		no_flag<= 1'b0;
	else if(cnt_1s == 32'd0)
		no_flag <=1'b1;
	else if(cnt_1s == 32'd9599999)
		no_flag <=1'b0;

	else
	no_flag<= no_flag;
endmodule

```
我仿真只是给上面的音谱指定了ROM，仿真波形如下：
![](./pic/音乐播放.png)

### 4、音谱和图像数据分配
因为音谱和图像数据的大小并不是一样的，我为了简化处理，选择了只在一开始让上位机发送两首歌的音谱，然后不再接收音谱数据，而是全接收图像的数据。
因此在串口到LCD和蜂鸣器之间就要增加一个处理，来决定串口的数据给谁和谁用串口发数据。具体实现代码如下：
``` verilog 
module In_Out_Handle (input				clk,
                      input				rst_n,
                      input		[3:0]	col,
                      output	 [3:0]	row,
                      input         uart_rx,
                      output        uart_tx,
                      output	reg				rx_data_valid_temp,
                      output	reg		[7:0]	rx_data_out_temp,
                      input					    tx_data_valid_temp,
                      input			    [7:0]	tx_data_in_temp,
                      output led_song,
                      output			beeper);
    
    parameter SIZE_MUSIC_MAX = 8'd83;
    wire rx_data_valid;
    wire [7:0]	rx_data_out;

    reg tx_data_valid;
    reg [7:0]	tx_data_in;

    reg tx_data_valid_here;;
    reg [7:0]	tx_data_in_here;;

    reg rx_data_valid_here;
    reg [7:0] rx_data_out_here;

    reg songs_choose;

    assign led_song = songs_choose;

    reg [7:0] rx_addr_in_index;
    reg [4:0] rx_data_temp;
    wire [7:0] addr_out_index;
    wire [4:0] out_data; 
    reg W_EN;
    reg finished_music_RX;
    reg back_music_RX;
    // reg switch_picture;

    reg switch_pulse;

    wire			[15:0]	key_out;
    wire			[15:0]	key_pulse;
    //Array_KeyBoard
    array_keyboard u1(
    .clk(clk),
    .rst_n(rst_n),
    .col(col),
    .row(row),
    .key_out(key_out),
    .key_pulse(key_pulse)
    );

reg [1:0]switch_counters;
always @ (posedge clk or negedge rst_n)
    if (!rst_n)  
        switch_counters <= 0;
    else if(switch_pulse==1'b1)
        switch_counters <= switch_counters +1'd1;
    else if(switch_counters == 2'd2)
        switch_counters <= 0;
    else
    switch_counters <= switch_counters;
always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
        songs_choose <= 1'b0;
        switch_pulse <= 1'b0;
    end
    else if(!key_out[0] && key_pulse)
        songs_choose <= 1'b1 ;
    else if(!key_out[1]  && key_pulse)
        songs_choose <= 1'b0 ;   
    else if(!key_out[2] && key_pulse)
        switch_pulse <= 1'b1;
    else if(switch_counters==1'b1)
        switch_pulse <= 1'b0; 
    else begin
        songs_choose <= songs_choose ;
         switch_pulse <= switch_pulse ;
    end

    uart_bus u2(
    .clk(clk),							//12MHz
    .rst_n(rst_n),						//

    .uart_rx(uart_rx),				//UART
    .rx_data_valid(rx_data_valid),//
    .rx_data_out(rx_data_out),		//
    
    .tx_data_valid(tx_data_valid),	//
    .tx_data_in(tx_data_in),		//
    .uart_tx(uart_tx)			//UART
    );
    
    electric_piano u_electric_piano(
    .clk(clk),			//system clock
    .rst_n(rst_n),		//system reset
    // .col(col),
    // .row(row),
    .addr(addr_out_index),
    .data(out_data),
    .songs_choose(songs_choose),
    .beeper(beeper)
    );

    music_store_ram u_music_store_ram(
    .clk(clk),                     //
    .addra(rx_addr_in_index),    //
    .dina(rx_data_out_here[4:0]),    //
    .W_EN(W_EN),
    .addrb(addr_out_index),    //
    .doutb(out_data)
    );

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
      rx_data_out_temp <= 0;
      rx_data_valid_temp <= 0;

      rx_data_out_here <= 0;
      rx_data_valid_here <=0;
    end

    else if(W_EN) begin
         rx_data_out_here <= rx_data_out;
         rx_data_valid_here <= rx_data_valid;

         rx_data_valid_temp <= 0;
    end
    else if(!W_EN) begin
        rx_data_out_temp <= rx_data_out;
        rx_data_valid_temp <= rx_data_valid;
        
        rx_data_valid_here <= 0;
    end
    
    else begin
        rx_data_out_temp <=  rx_data_out_temp;
        rx_data_valid_temp<=  rx_data_out_here;

        rx_data_out_here <= rx_data_out_here;
        rx_data_valid_here <= rx_data_valid_here;
    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
    
    end

    else if(switch_pulse) begin 
         tx_data_valid<= 1'b1;
         tx_data_in <= 8'd66;
    end

    else if(!W_EN) begin
         tx_data_valid<= tx_data_valid_temp;
         tx_data_in <= tx_data_in_temp ;
    end

    else if(W_EN) begin
         tx_data_valid<= tx_data_valid_here;
         tx_data_in <= tx_data_in_here ;
    end

    else begin
      tx_data_in <= tx_data_in;
      tx_data_valid <= tx_data_valid;

    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)   begin 
        W_EN <= 1'b1;
        tx_data_valid_here <= 1'b0;
        tx_data_in_here <= 8'd0;
    end
    else if(back_music_RX) begin 
        W_EN <= 1'b0;
        tx_data_valid_here <= 1'b0;
        
      end

    else if(finished_music_RX) begin 
        
        tx_data_valid_here <= 1'b1;
        tx_data_in_here <= 8'd66;
    end
    else begin 
        W_EN <= W_EN ;
        tx_data_valid_here <= tx_data_valid_here ;
        tx_data_in_here <=tx_data_in_here ;

    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  
        back_music_RX <= 1'b0;

    else if(finished_music_RX) 
        back_music_RX <= 1'b1;
    else
    back_music_RX <= back_music_RX ;

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
        rx_addr_in_index <= 8'd0;
        finished_music_RX          <= 1'b0;
    end

    else if (rx_addr_in_index == SIZE_MUSIC_MAX)
    begin
        // finished_music_RX             <= 1'b0;
        finished_music_RX          <= 1'b1;
    end
    else if (rx_addr_in_index < SIZE_MUSIC_MAX && rx_data_valid_here)
    begin
    rx_addr_in_index <= rx_addr_in_index + 8'd1;
 
    end
    else
        begin
        rx_addr_in_index  <=  rx_addr_in_index;
        finished_music_RX          <=  finished_music_RX;	
    end
endmodule
```
仿真中我用了一个信号来模拟图片切换，向上位机请求。testbench如下：
``` verilog

`timescale 1ns / 100ps

module UART_music_tb();
parameter CLK_PERIOD = 8; 
 
reg clk;
initial clk = 1'b0;
always #(CLK_PERIOD/2) clk = ~clk;

reg rst_n;  //active low
initial begin
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
end
parameter SIZE_MUSIC_MAX = 8'd83;
reg               uart_rx;
wire              uart_tx;

reg				rx_data_valid_temp;
reg		[7:0]	rx_data_out_temp;
reg			    tx_data_valid_temp;
reg	    [7:0]   tx_data_in_temp;

initial tx_data_valid_temp= 0;
initial tx_data_in_temp= 0;
    wire rx_data_valid;
    wire [7:0]	rx_data_out;

    reg tx_data_valid;
    reg [7:0]	tx_data_in;
                      


    reg tx_data_valid_here;
    reg [7:0]	tx_data_in_here;

    reg rx_data_valid_here;
    reg [7:0] rx_data_out_here;

    reg songs_choose;

    reg [7:0] rx_addr_in_index;
    // reg [4:0] rx_data_temp;
    // reg [7:0] addr_out_index;
    wire [4:0] out_data; 
    reg W_EN;
    reg finished_music_RX;
    reg back_music_RX;

    reg switch_picture;
    initial switch_picture=0;
    reg switch_picture_r;
    initial switch_picture_r=0;

    reg switch_pulse;
    // initial switch_pulse=0;
initial begin
	#200;
	rx_byte(); //调用任务rx_byte

    #50;

    #2;

    #200;
    // rx_byte();
    switch_picture=1;
    #10;
    switch_picture=0;
    end
 
task rx_byte();
	integer j;
	for(j=0;j<100;j=j+1)
    begin
		rx_bit(j);  //调用8次rx_bit任务，分别发送0-7
        #(20);
	end
endtask
 
task rx_bit(
	input [7:0] data
);
	integer i;
	for(i=0;i<10;i=i+1)begin
		case(i)
			'd0: uart_rx=1'b0;	//发送起始位
			'd1: uart_rx=data[0];
			'd2: uart_rx=data[1];
			'd3: uart_rx=data[2];
			'd4: uart_rx=data[3];
			'd5: uart_rx=data[4];
			'd6: uart_rx=data[5];
			'd7: uart_rx=data[6];
			'd8: uart_rx=data[7];
			'd9: uart_rx=1'b1;	//发送停止位
			default uart_rx=1'b1;
		endcase
	    #(10*8);
	end
endtask

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  
        switch_pulse <=0;
    else if(switch_picture) switch_pulse <= 1;
    else if(!switch_picture) switch_pulse <= 0;

    else switch_pulse <= switch_pulse;

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
      rx_data_out_temp <= 0;
      rx_data_valid_temp <= 0;

      rx_data_out_here <= 0;
      rx_data_valid_here <=0;
    end

    else if(W_EN) begin
         rx_data_out_here <= rx_data_out;
         rx_data_valid_here <= rx_data_valid;

         rx_data_valid_temp <= 0;
    end
    else if(!W_EN) begin
        rx_data_out_temp <= rx_data_out;
        rx_data_valid_temp <= rx_data_valid;
        
        rx_data_valid_here <= 0;
    end
    
    else begin
        rx_data_out_temp <=  rx_data_out_temp;
        rx_data_valid_temp<=  rx_data_out_here;

        rx_data_out_here <= rx_data_out_here;
        rx_data_valid_here <= rx_data_valid_here;
    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin

    end
    else if(switch_pulse) begin 
         tx_data_valid<= 1'b1;
         tx_data_in <= 8'd66;
    end 
    else if(!W_EN) begin
         tx_data_valid<= tx_data_valid_temp;
         tx_data_in <= tx_data_in_temp ;
    end

    else if(W_EN) begin
         tx_data_valid<= tx_data_valid_here;
         tx_data_in <= tx_data_in_here ;
    end

    else begin
      tx_data_in <= tx_data_in;
      tx_data_valid <= tx_data_valid;

    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)   begin 
        W_EN <= 1'b1;
        tx_data_valid_here <= 1'b0;
        tx_data_in_here <= 8'd0;
    end
    else if(back_music_RX) begin 
        W_EN <= 1'b0;
        tx_data_valid_here <= 1'b0;
        
      end
    else if(finished_music_RX) begin 
        
        tx_data_valid_here <= 1'b1;
        tx_data_in_here <= 8'd66;
    end
    else begin 
        W_EN <= W_EN ;
        tx_data_valid_here <= tx_data_valid_here ;
        tx_data_in_here <=tx_data_in_here ;

    end

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  
        back_music_RX <= 1'b0;

    else if(finished_music_RX) 
        back_music_RX <= 1'b1;
    else
    back_music_RX <= back_music_RX ;

always @ (posedge clk or negedge rst_n)
    if (!rst_n)  begin
        rx_addr_in_index <= 8'd0;
        finished_music_RX          <= 1'b0;
    end

    else if (rx_addr_in_index == SIZE_MUSIC_MAX)
    begin
        // finished_music_RX             <= 1'b0;
        finished_music_RX          <= 1'b1;
    end
    else if (rx_addr_in_index < SIZE_MUSIC_MAX && rx_data_valid_here)
    begin
    rx_addr_in_index <= rx_addr_in_index + 8'd1;
    end
    else
        begin
        rx_addr_in_index  <=  rx_addr_in_index;
        finished_music_RX          <=  finished_music_RX;	
    end

    uart_bus u2(
    .clk(clk),							//12MHz
    .rst_n(rst_n),						//

    .uart_rx(uart_rx),				//UART
    .rx_data_valid(rx_data_valid),//
    .rx_data_out(rx_data_out),		//
    
    .tx_data_valid(tx_data_valid),	//
    .tx_data_in(tx_data_in),		//
    .uart_tx(uart_tx)			//UART
    );
endmodule

```
仿真波形如下：
![](./pic/切换图片.png)
当图片切换脉冲来到时，串口发送66(字符B的ASCII码).

### 5、上位机程序
上位机主要涉及到串口输入输出，图像读取，显示，转换。因此可以用python写一个简单的脚本处理，我这里用的pycharm写的，很方便。
具体代码实现如下：
``` python
from PIL import Image
import serial
import time
# 打开串口
ser = serial.Serial('COM12', 96000)  # 更改为你的串口号和波特率
# 准备图片列表
image_files = ["D:/1my_program_study/2024_winter_task/STEP_FPGA/2.jpg", "D:/1my_program_study/2024_winter_task/STEP_FPGA/3.jpg", "D:/1my_program_study/2024_winter_task/STEP_FPGA/4.jpg"]  # 图片文件列表
index_times=0
byte_array_hex1 = ['08', '08', '0C', '0C', '0D', '0D', '0C', '00',
                      '0B', '0B', '0A', '0A', '09', '09', '08', '00',
                      '0C', '0C', '0B', '0B', '0A', '0A', '09', '00',
                      '0C', '0C', '0B', '0B', '0A', '0A', '09', '00',
                      '08', '08', '0C', '0C', '0D', '0D', '0C', '00',
                      '0B', '0B', '0A', '0A', '09', '09', '08', '00']
byte_array_hex2 = ['08', '09', '0A', '08', '08', '09', '0A', '08', '0A', '0B', '0C', '00',
                   '0A', '0B', '0C', '00',
                   '0C', '0D', '0C', '0B', '0A', '08', '0C', '0D',
                   '0C', '0B', '0A', '08', '09', '0C', '09', '08',
                   '09', '0C', '09', '08']

# 发送十六进制数据
def send_hex_data(byte_array_hex):
    try:
        for hex_str in byte_array_hex:
            byte = bytes.fromhex(hex_str)  # 将十六进制字符串转换为字节
            ser.write(byte)
    finally:
        # 关闭串口
       return
# 发送两首歌音谱
send_hex_data(byte_array_hex1)
send_hex_data(byte_array_hex2)

try:
    while True:
        # 发送图像数据
        for image_file in image_files:
            # 打开图像文件
            index_times =index_times+1
            image = Image.open(image_file)

            # 将图像缩放到指定大小并居中
            width, height = 240, 320
            image = image.resize((width, height), Image.LANCZOS)
            left = (width - image.width) // 2
            top = (height - image.height) // 2
            right = left + image.width
            bottom = top + image.height
            cropped_image = image.crop((left, top, right, bottom))

            # 获取图像的尺寸
            width, height = cropped_image.size

            # 将颜色数据转换为字节数组并发送
            try:
                for y in range(height):#height
                    print("index:"+str(index_times)+"num:" + str(y))
                    row_data = bytearray()
                    for x in range(width):
                        r, g, b = cropped_image.getpixel((x, y))
                        # 将RGB值转换为16位整数
                        color = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
                        # 将颜色数据转换为字节数组
                        row_data.extend(color.to_bytes(2, byteorder='big'))
                    # 发送数据并等待接收字符'A'
                    ser.write(row_data)
                    while ser.read() != b'A':
                        pass
                    # 等待接收到字符'B'后继续发送下一张图片

            finally:
                while ser.read() != b'B':
                    pass
                time.sleep(1)

finally:
    ser.close()
```


## 四、效果展示与遇到的问题

### 效果展示
我用来显示的图片如下
![](./pic/2-4图片.png)

运行时上位机输出
![](./pic/上位机.png)

第一张图片传输完成
![](./pic/1.png)

按下按键，音乐切换，核心板上最左边的灯熄灭
![](./pic/2.png)

第二张图片传输中
![](./pic/3.png)

第二张图片传输完成
![](./pic/4.png)

第三张图片传输中
![](./pic/5.png)

第三张图片传输完成
![](./pic/6.png)

音乐切换可能不好看出来，可见视频。
FPGA资源使用
![](./pic/资源使用.png)
### 遇到的问题
**1、** 目前的串口传输波特率虽然已经改成了96000，但还是很慢，之前默认的9600更慢。
**2、** 蜂鸣器播放的音乐还是不怎么好听，还得换成喇叭才行。
**3、** 音乐只有两首，还很短。还只能在一开始从串口接收音谱，然后在内部RAM中索引切换，还没找到办法可以一直同时改图片和音谱。

## 五、未来的计划与感想

**1、** 这次只是用小脚丫FPGA做了一个简单的小作业，我个人还是觉得FPGA做示波器才是浪漫，哈哈。立个flag,有时间用小脚丫做示波器。
**2、** 这次长教训了，最后一周才开始干，熬了好几个晚上终于做完了。不过好像这样的dead line ~~效率很高？~~ ，以后还是别这么干好了（身体要受不了了）。
**3、** 最后还是感谢硬禾给我们提供了这样的活动，有机会扩展自己的知识面，虽然自己是做嵌入式的，不做FPGA（快一年没碰了），但不妨碍我作为自己的小兴趣，哈哈。希望这样的活动会一直办下去~

