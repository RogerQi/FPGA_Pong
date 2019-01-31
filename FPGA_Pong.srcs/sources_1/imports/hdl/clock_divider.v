module clock_divider(input clk_in, output clk_out);

    parameter
      counter_lim = 50000;

    reg [31:0] counter = 1;
    reg temp_clk = 0;
    always @ (posedge(clk_in)) begin
        if (counter == counter_lim) begin //1 / (2n)
            counter <= 1;
            temp_clk <= ~temp_clk;
        end else begin
            counter <= counter + 1;
        end
    end
    assign clk_out = temp_clk;
endmodule
