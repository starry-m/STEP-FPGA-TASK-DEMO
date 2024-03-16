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

// assign switch_pulse= switch_picture & ( ~switch_picture_r);

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
    // else if(!switch_pulse) begin 
    //      tx_data_valid<= 1'b0;
    // end 
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


