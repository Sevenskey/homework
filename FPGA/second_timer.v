module segment_displays_7 ( clk, reset, min0, min1, sec0, sec1 );
    input clk, reset;
    output [7:0]min0, min1, sec0, sec1;

    wire clk_sec;
    wire [15:0]num;

    dfrequency A0 ( clk, clk_sec );
    counter A1 ( clk_sec, num[15:0], reset );
    trans_code_pattern T0 ( num[3:0], sec0[7:0] );
    trans_code_pattern T1 ( num[7:4], sec1[7:0] );
    trans_code_pattern T2 ( num[11:8], min0[7:0] );
    trans_code_pattern T3 ( num[15:12], min1[7:0] );
endmodule

// 分频
// input: 50MHz时钟信号 output: 秒脉冲
module dfrequency ( clk, clk_sec );
    input clk;
    output clk_sec;

    reg clk_sec;
    reg [25:0]flag = 26'd0;

    always @ ( posedge clk )
    begin
        if ( flag == 26'd49999999 )
        begin
            flag = 26'd0;
            clk_sec = 1;
        end
        else
        begin
            flag = flag + 1;
            clk_sec = 0;
        end
    end
endmodule

// 码型转换
// input: 十进制个位数 output: 对应段码
module trans_code_pattern ( before_num, after_num );
    input [3:0]before_num;
    output [7:0]after_num;

    reg [7:0]after_num;

    always @ ( before_num )
    begin
        case ( before_num )
            4'd0 : after_num <= 8'b11000000;
            4'd1 : after_num <= 8'b11111001;
            4'd2 : after_num <= 8'b10100100;
            4'd3 : after_num <= 8'b10110000;
            4'd4 : after_num <= 8'b10011001;
            4'd5 : after_num <= 8'b10010010;
            4'd6 : after_num <= 8'b10000010;
            4'd7 : after_num <= 8'b11111000;
            4'd8 : after_num <= 8'b10000000;
            4'd9 : after_num <= 8'b10010000;
            default : ;
        endcase
    end
endmodule

// N进制计数器（十六进制以内）
// input: 时钟脉冲，清零信号 output: 4位计数，进位
module n_counter ( clk, nout, cout, reset );
    parameter num = 4'd10;

    input clk, reset;
    output cout;
    output [3:0]nout;

    reg [3:0]nout = 4'd0;
    reg cout = 0;

    always @ ( posedge clk or posedge reset )
    begin
        if ( reset )
            nout = 4'd0;
        else
        begin
            nout = nout + 1;
            if ( nout == num )
            begin
                cout = 1;
                nout = 4'd0;
            end
            else 
                cout = 0;
        end
    end
endmodule

// 十进制计数器
module decimal_counter ( clk, nout, cout, reset );
    input clk, reset;
    output cout;
    output [3:0]nout;

    defparam A0.num = 4'd10;

    n_counter A0 ( clk, nout, cout, reset );
endmodule

// 六进制计数器
module senary_counter ( clk, nout, cout, reset );
    input clk, reset;
    output cout;
    output [3:0]nout;

    defparam A0.num = 4'd6;

    n_counter A0 ( clk, nout, cout, reset );
endmodule

// 分秒计数器
// input: 时钟脉冲，清零信号 output: 16位计数
// 16位计数格式：xxxx xxxx xxxx xxxx
//              min1 min0 sec1 sec0
module counter ( clk, out, reset );
    input clk, reset;
    output [15:0]out;

    wire clk1, clk2, clk3, clk4;

    decimal_counter A0 ( clk, out[3:0], clk1, reset );
    senary_counter A1 ( clk1, out[7:4], clk2, reset );
    decimal_counter A2 ( clk2, out[11:8], clk3, reset );
    senary_counter A3 ( clk3, out[15:12], clk4, reset );
endmodule
