`timescale 1ns/1ps
module tb_median();
    parameter TB_W     = 430;
    parameter TB_H     = 554;
    parameter TB_DW    = 8;
    parameter TB_TOTAL = TB_W * TB_H;  

    reg  clk_tb, rst_tb;
    reg  in_vld_tb;
    reg  [TB_DW-1:0] in_pix_tb;
    wire out_vld_tb;
    wire [TB_DW-1:0] out_pix_tb;

    integer rd_cnt_tb, wr_cnt_tb, file_out_tb;
    reg [TB_DW-1:0] mem_tb [0:TB_TOTAL-1];

    mf_core #(
        .IMG_W(TB_W),
        .IMG_H(TB_H),
        .DW   (TB_DW)
    ) dut (
        .clk_i    (clk_tb),
        .rst_i    (rst_tb),
        .din_valid(in_vld_tb),
        .din_pixel(in_pix_tb),
        .dout_valid(out_vld_tb),
        .dout_pixel(out_pix_tb)
    );

    initial clk_tb = 0;
    always #5 clk_tb = ~clk_tb;

    always @(posedge clk_tb) begin
        if (rst_tb) begin
            in_vld_tb  <= 0;
            in_pix_tb  <= 0;
            rd_cnt_tb  <= 0;
        end else begin
            if (rd_cnt_tb < TB_TOTAL) begin
                in_vld_tb <= 1;
                in_pix_tb <= mem_tb[rd_cnt_tb];
                rd_cnt_tb <= rd_cnt_tb + 1;
            end else begin
                in_vld_tb <= 0;
                in_pix_tb <= 0;
            end
        end
    end

    always @(posedge clk_tb) begin
        if (rst_tb) begin
            wr_cnt_tb <= 0;
        end else begin
            if (out_vld_tb) begin
                $fwrite(file_out_tb, "%02h\n", out_pix_tb);
                wr_cnt_tb <= wr_cnt_tb + 1;
            end
        end
    end

    initial begin
        rst_tb = 1;
        in_vld_tb = 0;
        in_pix_tb = 0;
        rd_cnt_tb = 0;
        wr_cnt_tb = 0;

        $readmemh("pic_input.txt", mem_tb);

        file_out_tb = $fopen("pic_output.txt", "w");
        if (!file_out_tb) begin
            $display("Cannot open pic_output.txt");
            $finish;
        end

        #20 rst_tb = 0;

        wait(wr_cnt_tb >= TB_TOTAL);
        #50;

        $fclose(file_out_tb);
        $finish;
    end

endmodule