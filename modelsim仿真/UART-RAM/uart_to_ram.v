
/*
 1+8+1=10�???
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
//采用16进制格式，接收到的数据等于数值本�???
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

        .tx_data_valid(tx_data_valid),	//发送数据有效脉�
		.tx_data_in(tx_data_out),		//要发送的数据
		.uart_tx(uart_tx)			//UART发送输�
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
