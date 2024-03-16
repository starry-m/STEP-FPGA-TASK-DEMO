module music_rom
(
    input wire [7:0]address,
    output reg [4:0]data
);
always @ (*)
		case(address)
            8'd0  : data = 5'd8;// 1155 6650
            8'd1  : data = 5'd8;
            8'd2  : data = 5'd12;
            8'd3  : data = 5'd12;
            8'd4  : data = 5'd13;
            8'd5  : data = 5'd13;
            8'd6  : data = 5'd12;
            8'd7  : data = 5'd0;

            8'd8  : data = 5'd11;// 4433 2210
            8'd9  : data = 5'd11;
            8'd10  : data = 5'd10;
            8'd11  : data = 5'd10;
            8'd12  : data = 5'd9;
            8'd13  : data = 5'd9;
            8'd14  : data = 5'd8;
            8'd15  : data = 5'd0;        
            

            8'd16  : data = 5'd12;// 5544 3320
            8'd17  : data = 5'd12;
            8'd18  : data = 5'd11;
            8'd19  : data = 5'd11;
            8'd20  : data = 5'd10;
            8'd21  : data = 5'd10;
            8'd22  : data = 5'd9;
            8'd23  : data = 5'd0;

            8'd24  : data = 5'd12;//  5544 3320
            8'd25  : data = 5'd12;
            8'd26  : data = 5'd11;
            8'd27  : data = 5'd11;
            8'd28  : data = 5'd10;
            8'd29  : data = 5'd10;
            8'd30  : data = 5'd9;
            8'd31  : data = 5'd0;

            8'd32  : data = 5'd8;// 1155 6650
            8'd33  : data = 5'd8;
            8'd34  : data = 5'd12;
            8'd35  : data = 5'd12;
            8'd36  : data = 5'd13;
            8'd37  : data = 5'd13;
            8'd38  : data = 5'd12;
            8'd39  : data = 5'd0;

            8'd40  : data = 5'd11;// 4433 2210
            8'd41  : data = 5'd11;
            8'd42  : data = 5'd10;
            8'd43  : data = 5'd10;
            8'd44  : data = 5'd9;
            8'd45  : data = 5'd9;
            8'd46  : data = 5'd8;
            8'd47  : data = 5'd0;

            default:data = 0;
        endcase


endmodule
