`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc
// Engineer: Arthur Brown
//
// Create Date: 07/27/2016 02:04:01 PM
// Design Name: Basys3 Keyboard Demo
// Module Name: top
// Project Name: Keyboard
// Target Devices: Basys3
// Tool Versions: 2016.X
// Description:
//     Receives input from USB-HID in the form of a PS/2, displays keyboard key presses and releases over USB-UART.
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//     Known issue, when multiple buttons are pressed and one is released, the scan code of the one still held down is ometimes re-sent.
//////////////////////////////////////////////////////////////////////////////////

`define key_w 8'h1d
`define key_a 8'h1c
`define key_s 8'h1b
`define key_d 8'h23

`define key_up 8'h75
`define key_left 8'h6b
`define key_down 8'h72
`define key_right 8'h74

module top(
    input         clk,
    input         PS2Data,
    input         PS2Clk,
    input btnC,
    output [6:0] seg,
    output [3:0] an,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output Hsync,
    output Vsync
);
    reg         start=0;
    reg         CLK50MHZ=0;
    reg  [15:0] keycodev=0;
    wire [15:0] keycode;
    reg  [ 2:0] bcount=0;
    wire        flag;
    reg         cn=0;
    reg reset = 1'b1; //init to be reset first

    always @(posedge(clk))begin
        CLK50MHZ<=~CLK50MHZ;
        reset <= btnC;
    end

    /* Start Keyboard control logic */
    PS2Receiver uut (
        .clk(CLK50MHZ),
        .kclk(PS2Clk),
        .kdata(PS2Data),
        .keycode(keycode),
        .oflag(flag)
    );

    always@(keycode)
        if (keycode[7:0] == 8'hf0) begin
            cn <= 1'b0;
            bcount <= 3'd0;
        end else if (keycode[15:8] == 8'hf0) begin
            cn <= keycode != keycodev;
            bcount <= 3'd5;
        end else begin
            cn <= keycode[7:0] != keycodev[7:0] || keycodev[15:8] == 8'hf0;
            bcount <= 3'd2;
        end

    always@(posedge clk) begin
        if (flag == 1'b1 && cn == 1'b1) begin
            start <= 1'b1;
            keycodev <= keycode;
        end else
            start <= 1'b0;
    end

    //key fsm
    wire w_pressed, s_pressed, up_pressed, down_pressed;
    key_fsm #(`key_w) w_fsm(.key_pressed(w_pressed), .keycode(keycodev), .clk(clk), .reset(reset));
    key_fsm #(`key_s) s_fsm(.key_pressed(s_pressed), .keycode(keycodev), .clk(clk), .reset(reset));
    key_fsm #(`key_up) up_fsm(.key_pressed(up_pressed), .keycode(keycodev), .clk(clk), .reset(reset));
    key_fsm #(`key_down) down_fsm(.key_pressed(down_pressed), .keycode(keycodev), .clk(clk), .reset(reset));

    /* End Keyboard control logic */

    /* Start VGA control logic and color renderer */
    //blocks
    wire vga_clk;
    wire [9:0] draw_x, draw_y;
    wire is_paddle, is_paddle_left, is_paddle_main;
    assign is_paddle = is_paddle_left | is_paddle_main;

    wire is_square;
    wire [9:0] debug;

    wire [9:0] true_draw_x, true_draw_y;
    assign true_draw_x = draw_x - 10'd159;
    assign true_draw_y = draw_y - 10'd45;
    /* VGA Units */
    clock_divider #(2) vga_clk_maker(.clk_in(clk), .clk_out(vga_clk));
    VGA_controller vc(.Reset(reset), .VGA_HS(Hsync), .VGA_VS(Vsync), .VGA_CLK(vga_clk), .draw_x(draw_x), .draw_y(draw_y));
    color_renderer c_renderer(.red(vgaRed), .green(vgaGreen), .blue(vgaBlue), .is_paddle(is_paddle), .is_square(is_square),
        .draw_x(draw_x), .draw_y(draw_y), .clk(vga_clk));

    /* End VGA */

    /* Hex driver*/
    wire [7:0] left_score, right_score;
    hex_driver hd(.seg(seg), .an(an), .tho_dig(left_score[7:4]), .hun_dig(left_score[3:0]), .ten_dig(right_score[7:4]), .lsb_dig(right_score[3:0]), .CLK_50MHZ(CLK50MHZ));

    /* Main game control logic */

    main_game_coordinator master(.is_square(is_square), .is_paddle_main(is_paddle_main), .is_paddle_left(is_paddle_left),
        .clk(clk), .reset(reset), .draw_x(true_draw_x), .draw_y(true_draw_y), .frame_clk(Vsync),
        .w_pressed(w_pressed), .s_pressed(s_pressed), .up_pressed(up_pressed), .down_pressed(down_pressed), .left_score(left_score), .right_score(right_score));

endmodule
