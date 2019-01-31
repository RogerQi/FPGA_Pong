module main_game_coordinator(output is_square, output is_paddle_main, output is_paddle_left,
    input clk, input reset, input [9:0] draw_x, input [9:0] draw_y, input frame_clk,
    input w_pressed, input s_pressed, input up_pressed, input down_pressed, output [7:0] left_score, output [7:0] right_score);

    `include "game_param.vh"

    wire [9:0] square_x_center, square_y_center;
    wire [9:0] left_paddle_y;
    wire [9:0] right_paddle_y;

    reg hit_left_paddle_y;
    reg hit_left_paddle_x;
    reg hit_left_paddle;

    reg hit_right_paddle_x;
    reg hit_right_paddle_y;
    reg hit_right_paddle;

    reg [9:0] square_x_center_delayed;
    reg [7:0] left_lose_cnt = 8'b0;
    reg [7:0] right_lose_cnt = 8'b0;

    assign left_score = right_lose_cnt;
    assign right_score = left_lose_cnt;

    reg round_end;
    wire new_round = round_end | reset;

    wire left_start = up_pressed | down_pressed;
    wire right_start = w_pressed | s_pressed;

    always @ (posedge clk) begin
        if (reset) begin
            left_lose_cnt <= 8'b0;
            right_lose_cnt <= 8'b0;
        end
        square_x_center_delayed <= square_x_center;
        round_end <= 1'b0;

        if ((square_x_center_delayed < 10'd150) && (square_x_center[9] == 1'b1)) begin
            left_lose_cnt <= left_lose_cnt + 1'b1;
            round_end <= 1'b1;
        end
        
        if ((square_x_center > vga_width) && square_x_center_delayed > 10'd500) begin
            right_lose_cnt <= right_lose_cnt + 1'b1;
            round_end <= 1'b1;
        end

        hit_left_paddle_y <= (square_y_center >= left_paddle_y) && (square_y_center <= left_paddle_y + paddle_height);
        hit_left_paddle_x <= (square_x_center <= left_paddle_width);
        hit_left_paddle <= hit_left_paddle_x && hit_left_paddle_y;

        //assign hit_right_paddle_x = ((square_x_center - 10'd130) >= 10'sd500); //640 - 10 - 130
        hit_right_paddle_x <= ((square_x_center) >= (vga_width - paddle_width));
        hit_right_paddle_y <= (square_y_center >= right_paddle_y) && (square_y_center <= right_paddle_y + paddle_height);
        hit_right_paddle <= hit_right_paddle_x && hit_right_paddle_y;
    end

    main_control main_paddle(.is_paddle(is_paddle_main), .clk(clk), .reset(new_round), .draw_x(draw_x), .draw_y(draw_y), .frame_clk(frame_clk), //need to be modified!
        .w_pressed(up_pressed), .s_pressed(down_pressed), .right_paddle_y(right_paddle_y));
    
    left_control left_paddle(.is_paddle(is_paddle_left), .clk(clk), .reset(new_round), .draw_x(draw_x), .draw_y(draw_y), .frame_clk(frame_clk), //need to be modified!
        .u_pressed(w_pressed), .d_pressed(s_pressed), .left_paddle_y(left_paddle_y));

    square_control my_sqaure(.is_square(is_square), .clk(clk), .reset(new_round), .draw_x(draw_x), .draw_y(draw_y), .frame_clk(frame_clk),
        .start_left(left_start), .start_right(right_start), .hit_left_paddle(hit_left_paddle), .hit_right_paddle(hit_right_paddle),
        .square_x_center(square_x_center), .square_y_center(square_y_center));

endmodule
