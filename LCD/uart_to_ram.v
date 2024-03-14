
/*
 1+8+1=10�??
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
    
    //采用16进制格式，接收到的数据等于数值本�??
    parameter  PIC_SIZE      = 9'd153599;
    parameter SIZE_WIDTH_MAX = 9'd479;
    wire [7:0] rx_data_temp  = rx_data_out;
    reg [17:0]  rx_data_index;
    reg [8:0] addr_in_index;
    wire W_EN_temp=W_EN;
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
