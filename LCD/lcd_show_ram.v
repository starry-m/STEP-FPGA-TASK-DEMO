
`timescale 1 ns / 100 ps
//һ�α���20�е�16λ����,240*16*20
//����һ�а� 240*16=480*8
//��ʽ�����:SystemVerilog and Verilog Formatter
//lcd_show_ram.v
module lcd_show_ram #(
    parameter DATA_WDTH = 4'd8,  //�������ݵ�λ��
    parameter COL       = 480,   //RAM�����ݸ���
    parameter COL_BITS  = 9      //��ַ��λ��
) (
    input                 clk,    //ʱ���ź�
    input [ COL_BITS-1:0] addra,  //д�����ݵĵ�ַ
    input [DATA_WDTH-1:0] dina,   //д�������
    input                 W_EN,   //д��Ч�ź�

    input  [ COL_BITS-1:0] addrb,  //������ݵĵ�ַ
    output [DATA_WDTH-1:0] doutb   //���������
);

  reg [DATA_WDTH-1:0] mem[0:COL-1];  //����RAM

  assign doutb = mem[addrb+0];

  always @(posedge clk) begin
    if( W_EN == 1'b1 )							//д��Чʱ�򣬰�dinaд�뵽addra��
    begin
      mem[addra] <= dina;
    end else;
  end

endmodule
