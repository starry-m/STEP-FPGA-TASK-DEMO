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

                        8'd40  : data = 5'd11;// 4433 2210
            8'd41  : data = 5'd11;
            8'd42  : data = 5'd10;
            8'd43  : data = 5'd10;
            8'd44  : data = 5'd9;
            8'd45  : data = 5'd9;
            8'd46  : data = 5'd8;
            8'd47  : data = 5'd0;

            8'd48  : data = 5'd8;// 1155 6650
            8'd49  : data = 5'd8;
            8'd50  : data = 5'd12;
            8'd51  : data = 5'd12;
            8'd52  : data = 5'd13;
            8'd53  : data = 5'd13;
            8'd54  : data = 5'd12;
            8'd55  : data = 5'd0;

            8'd56  : data = 5'd11;// 4433 2210
            8'd57  : data = 5'd11;
            8'd58  : data = 5'd10;
            8'd59  : data = 5'd10;
            8'd60  : data = 5'd9;
            8'd61  : data = 5'd9;
            8'd62  : data = 5'd8;
            8'd63  : data = 5'd0;        
            

            8'd64  : data = 5'd12;// 5544 3320
            8'd65  : data = 5'd12;
            8'd66  : data = 5'd11;
            8'd67  : data = 5'd11;
            8'd68  : data = 5'd10;
            8'd69  : data = 5'd10;
            8'd70  : data = 5'd9;
            8'd71  : data = 5'd0;

            8'd72  : data = 5'd12;//  5544 3320
            8'd73  : data = 5'd12;
            8'd74  : data = 5'd11;
            8'd75  : data = 5'd11;
            8'd76  : data = 5'd10;
            8'd77  : data = 5'd10;
            8'd78  : data = 5'd9;
            8'd79  : data = 5'd0;

            8'd80  : data = 5'd8;// 1155 6650
            8'd81  : data = 5'd8;
            8'd82  : data = 5'd12;
            8'd83  : data = 5'd12;

            default:data = 0;
        endcase


endmodule
