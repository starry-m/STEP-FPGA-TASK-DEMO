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

// always @ (posedge clk or negedge rst_n)
//     if (!rst_n)  begin
//         switch_picture=0;
//     else if()
//         switch_picture=1;

//     else
//     switch_picture <= switch_picture;
// assign  songs_choose = key_out[0] ?1'b1:1'b0 ;   
// key_pulse posegde 0->1
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
    // else if(key_out[2] && !key_pulse)
    //     switch_pulse <= 1'b0;   
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
    
