//active low
//  -    0
// | | 5  1
//  -    6
// | | 4  2
//  -   3

`define zero 4'b0000
`define one 4'b0001
`define two 4'b0010
`define three 4'b0011
`define four 4'b0100
`define five 4'b0101
`define six 4'b0110
`define seven 4'b0111
`define eight 4'b1000
`define nine 4'b1001
//active low
module BCDToLED(output [6:0] seg, input [3:0] x);
    wire ten = (x == 4'b1010);
    wire eleven = (x == 4'b1011);
    wire twelve = (x == 4'b1100);
    wire thirteen = (x == 4'b1101);
    wire fourteen = (x == 4'b1110);
    wire fifteen = (x == 4'b1111);
    wire two_digit = ten | eleven | twelve | thirteen | fourteen | fifteen;

    assign seg[0] = (~two_digit & ((~x[3] & ~x[2] & ~x[1] & x[0]) | (x[2] & ~x[1] & ~x[0]))) | (eleven | thirteen);
    assign seg[1] = (~two_digit & ((x[2] & ~x[1] & x[0]) | (x[2] & x[1] & ~x[0]))) | (eleven | twelve | fourteen | fifteen);
    assign seg[2] = (~two_digit & ((~x[2] & x[1] & ~x[0]))) | (twelve | fourteen | fifteen);
    assign seg[3] = (~two_digit & ((~x[3] & ~x[2] & ~x[1] & x[0]) | (x[2] & ~x[1] & ~x[0]) | (x[2] & x[1] & x[0]))) | (ten | fifteen);
    assign seg[4] = (~two_digit & ((x[0]) | (x[2] & ~x[1])));
    assign seg[5] = (~two_digit & ((~x[3] & ~x[2] & x[0]) | (~x[3] & ~x[2] & x[1]) | (x[1] & x[0]))) | (thirteen);
    assign seg[6] = (~two_digit & ((~x[3] & ~x[2] & ~x[1]) | (x[2] & x[1] & x[0]))) | (twelve);
endmodule

module hex_driver(output [6:0] seg, output [3:0] an, input [3:0] tho_dig, input [3:0] hun_dig, input [3:0] ten_dig, input [3:0] lsb_dig, input CLK_50MHZ);
    wire [6:0] tho_seg, hun_seg, ten_seg, lsb_seg;
    wire sc_circuit_clk;

    BCDToLED btl_lsb(.seg(lsb_seg), .x(lsb_dig));
    BCDToLED btl_ten(.seg(ten_seg), .x(ten_dig));
    BCDToLED btl_hun(.seg(hun_seg), .x(hun_dig));
    BCDToLED btl_tho(.seg(tho_seg), .x(tho_dig));

    clock_divider #(100000) cd1(.clk_in(CLK_50MHZ), .clk_out(sc_circuit_clk));

    scan_control sc_circuit(.seg(seg), .an(an), .tho_seg(tho_seg), .hun_seg(hun_seg), .ten_seg(ten_seg), .lsb_seg(lsb_seg), .clk(sc_circuit_clk));
endmodule
