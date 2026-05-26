module mf_core #(
    parameter IMG_W = 430,
    parameter IMG_H = 554,
    parameter DW    = 8
)(
    input  wire clk_i,
    input  wire rst_i,
    input  wire din_valid,
    input  wire [DW-1:0] din_pixel,

    output reg  dout_valid,
    output reg  [DW-1:0] dout_pixel
);

    reg [15:0] wr_ptr;
    reg [31:0] cnt_in, cnt_out;
    reg [15:0] latency_cnt;
    reg [15:0] out_col, out_row;

    reg [DW-1:0] buf_a [0:IMG_W-1];
    reg [DW-1:0] buf_b [0:IMG_W-1];

    wire [DW-1:0] tap_a = buf_a[wr_ptr];
    wire [DW-1:0] tap_b = buf_b[wr_ptr];

    reg [DW-1:0] r00,r01,r02;
    reg [DW-1:0] r10,r11,r12;
    reg [DW-1:0] r20,r21,r22;

    integer i;

    wire shift_en = din_valid ||
                    (cnt_in == IMG_W*IMG_H && cnt_out < IMG_W*IMG_H);

    wire [DW-1:0] min0,min1,min2;
    wire [DW-1:0] med0,med1,med2;
    wire [DW-1:0] max0,max1,max2;
    wire [DW-1:0] t1,t2,t3,med_final;

    always @(posedge clk_i) begin
        if (rst_i) begin
            wr_ptr<=0; cnt_in<=0; cnt_out<=0;
            latency_cnt<=0; out_col<=0; out_row<=0;
            dout_valid<=0; dout_pixel<=0;
            r00<=0; r01<=0; r02<=0;
            r10<=0; r11<=0; r12<=0;
            r20<=0; r21<=0; r22<=0;
            for (i=0; i<IMG_W; i=i+1) begin
                buf_a[i]<=0; buf_b[i]<=0;
            end
        end
        else begin
            dout_valid <= 0;
            if (shift_en) begin
                if (din_valid) begin
                    buf_a[wr_ptr] <= din_pixel;
                    buf_b[wr_ptr] <= tap_a;
                end
                wr_ptr <= (wr_ptr == IMG_W-1) ? 0 : wr_ptr + 1;

                r20<=r21; r21<=r22; r22<=din_pixel;
                r10<=r11; r11<=r12; r12<=tap_a;
                r00<=r01; r01<=r02; r02<=tap_b;

                if (din_valid && cnt_in < IMG_W*IMG_H)
                    cnt_in <= cnt_in + 1;
                if (latency_cnt < IMG_W + 2)
                    latency_cnt <= latency_cnt + 1;

                if (latency_cnt >= IMG_W + 2 && cnt_out < IMG_W*IMG_H) begin
                    dout_valid <= 1;
                    dout_pixel <= med_final;
                    cnt_out    <= cnt_out + 1;
                    if (out_col == IMG_W-1) begin
                        out_col <= 0;
                        out_row <= out_row + 1;
                    end else
                        out_col <= out_col + 1;
                end
            end
        end
    end
	 
    wire [DW-1:0] w00,w01,w02,w10,w11,w12,w20,w21,w22;

    wire top_edge   = (out_row == 0);
    wire bot_edge   = (out_row == IMG_H-1);
    wire left_edge  = (out_col == 0);
    wire right_edge = (out_col == IMG_W-1);

    wire [DW-1:0] c00 = left_edge  ? r01 : (right_edge ? r01 : r00);
    wire [DW-1:0] c01 = r01;
    wire [DW-1:0] c02 = right_edge ? r01 : (left_edge  ? r01 : r02);
    wire [DW-1:0] c10 = left_edge  ? r11 : (right_edge ? r11 : r10);
    wire [DW-1:0] c11 = r11;
    wire [DW-1:0] c12 = right_edge ? r11 : (left_edge  ? r11 : r12);
    wire [DW-1:0] c20 = left_edge  ? r21 : (right_edge ? r21 : r20);
    wire [DW-1:0] c21 = r21;
    wire [DW-1:0] c22 = right_edge ? r21 : (left_edge  ? r21 : r22);

    assign w00 = top_edge ? c10 : (bot_edge ? c10 : c00);
    assign w01 = top_edge ? c11 : (bot_edge ? c11 : c01);
    assign w02 = top_edge ? c12 : (bot_edge ? c12 : c02);
    assign w10 = c10;
    assign w11 = c11;
    assign w12 = c12;
    assign w20 = bot_edge ? c10 : (top_edge ? c10 : c20);
    assign w21 = bot_edge ? c11 : (top_edge ? c11 : c21);
    assign w22 = bot_edge ? c12 : (top_edge ? c12 : c22);

    function [DW-1:0] f_max2; input [DW-1:0] a,b;
        begin f_max2=(a>b)?a:b; end endfunction
    function [DW-1:0] f_min2; input [DW-1:0] a,b;
        begin f_min2=(a<b)?a:b; end endfunction
    function [DW-1:0] f_max3; input [DW-1:0] a,b,c;
        begin f_max3=f_max2(f_max2(a,b),c); end endfunction
    function [DW-1:0] f_min3; input [DW-1:0] a,b,c;
        begin f_min3=f_min2(f_min2(a,b),c); end endfunction
    function [DW-1:0] f_med3; input [DW-1:0] a,b,c;
        begin f_med3=f_max2(f_min2(a,b),f_min2(f_max2(a,b),c)); end endfunction

    assign min0=f_min3(w00,w01,w02); assign med0=f_med3(w00,w01,w02); assign max0=f_max3(w00,w01,w02);
    assign min1=f_min3(w10,w11,w12); assign med1=f_med3(w10,w11,w12); assign max1=f_max3(w10,w11,w12);
    assign min2=f_min3(w20,w21,w22); assign med2=f_med3(w20,w21,w22); assign max2=f_max3(w20,w21,w22);

    assign t1=f_max3(min0,min1,min2);
    assign t2=f_med3(med0,med1,med2);
    assign t3=f_min3(max0,max1,max2);
    assign med_final=f_med3(t1,t2,t3);

endmodule