module scan_control(output [6:0] seg, output [3:0] an,
                    input [6:0] tho_seg, input [6:0] hun_seg, input [6:0] ten_seg, input [6:0] lsb_seg, input clk);
    reg s_lsb, s_ten, s_hun, s_tho;

    //assume run is active high
    reg s_garbage = 1;
    wire s_lsb_next = (s_garbage) | (s_tho);
    wire s_ten_next = s_lsb;
    wire s_hun_next = s_ten;
    wire s_tho_next = s_hun;

    always @ (posedge clk) begin
        s_garbage <= 0;
        s_lsb <= s_lsb_next;
        s_ten <= s_ten_next;
        s_hun <= s_hun_next;
        s_tho <= s_tho_next;
    end

    wire [6:0] lsb_out = ({7{(s_lsb)}} & lsb_seg);
    wire [6:0] ten_out = ({7{(s_ten)}} & ten_seg);
    wire [6:0] hun_out = ({7{(s_hun)}} & hun_seg);
    wire [6:0] tho_out = ({7{(s_tho)}} & tho_seg);

    wire [3:0] lsb_an_out = ({4{(s_lsb)}} & 4'b1110);
    wire [3:0] ten_an_out = ({4{(s_ten)}} & 4'b1101);
    wire [3:0] hun_an_out = ({4{(s_hun)}} & 4'b1011);
    wire [3:0] tho_an_out = ({4{(s_tho)}} & 4'b0111);

    assign seg = lsb_out | ten_out | hun_out | tho_out;
    assign an = lsb_an_out | ten_an_out | hun_an_out | tho_an_out;
endmodule
