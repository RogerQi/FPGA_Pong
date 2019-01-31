module main_control(output is_paddle, input clk, input reset, input [9:0] draw_x, input [9:0] draw_y, input frame_clk,
    input w_pressed, input s_pressed, output [9:0] right_paddle_y);

    //640*480
    `include "game_param.vh"

    wire [9:0] paddle_max = 10'd480 - paddle_height;
    wire [9:0] upper_center_temp = 10'd480 - paddle_height;
    wire [9:0] upper_center = {1'b0, upper_center_temp[9:1]}; // divided by 2

    //note that for paddle in pong, only y location matters.
    reg [9:0] paddle_pos;
    //reg [9:0] paddle_velocity; //pos is upper bound of the paddle (smallest y)
    wire [9:0] paddle_pos_in;
    //wire [9:0] paddle_velocity_in;
    reg frame_clk_delayed, frame_clk_rising_edge;

    assign right_paddle_y = paddle_pos;

    always @ (posedge clk or posedge reset) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
        if (reset) begin
            paddle_pos <= upper_center;
        end else begin
            paddle_pos <= paddle_pos_in;
        end
    end

    assign is_paddle = (draw_x > (x_max - paddle_width)) && (draw_y > paddle_pos) && (draw_y < paddle_pos + paddle_height);

    //mux
    reg [9:0] paddle_pos_new;
    //wire [9:0] paddle_velocity_new;
    mux2v #(10) pos_mux(.out(paddle_pos_in), .A(paddle_pos), .B(paddle_pos_new), .sel(frame_clk_rising_edge));
    //mux2v #(10) pos_vel(.out(paddle_velocity_in), .A(paddle_velocity), .B(paddle_velocity_new), .sel(frame_clk_rising_edge));

    always @ (frame_clk_rising_edge) begin
        //by default, do nothing
        paddle_pos_new <= paddle_pos;
        //move up
        if (w_pressed && (paddle_pos > step_size)) begin
            paddle_pos_new <= paddle_pos - step_size;
        end
        if (s_pressed && (paddle_pos + step_size) <= paddle_max) begin
            paddle_pos_new <= paddle_pos + step_size;
        end
    end
endmodule
