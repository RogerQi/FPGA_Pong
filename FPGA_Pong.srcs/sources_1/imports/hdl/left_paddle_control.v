module left_control(output is_paddle, input clk, input reset, input [9:0] draw_x, input [9:0] draw_y, input frame_clk,
    input u_pressed, input d_pressed, output [9:0] left_paddle_y);

    //640*480
    `include "game_param.vh"

    wire [9:0] paddle_max = 10'd480 - left_paddle_height;
    wire [9:0] upper_center_temp = 10'd480 - left_paddle_height;
    wire [9:0] upper_center = {1'b0, upper_center_temp[9:1]}; // divided by 2

    //note that for paddle in pong, only y location matters.
    reg [9:0] paddle_pos;
    //reg [9:0] paddle_velocity; //pos is upper bound of the paddle (smallest y)
    wire [9:0] paddle_pos_in;
    //wire [9:0] paddle_velocity_in;
    reg frame_clk_delayed, frame_clk_rising_edge;

    assign left_paddle_y = paddle_pos;

    always @ (posedge clk or posedge reset) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
        if (reset) begin
            paddle_pos <= upper_center;
            //paddle_velocity <= 10'b0;
        end else begin
            paddle_pos <= paddle_pos_in;
            //paddle_velocity <= paddle_velocity_in;
        end
    end

    assign is_paddle = (draw_x < left_paddle_width) && (draw_y > paddle_pos) && (draw_y < paddle_pos + left_paddle_height);

    //mux
    reg [9:0] paddle_pos_new;
    //wire [9:0] paddle_velocity_new;
    mux2v #(10) pos_mux(.out(paddle_pos_in), .A(paddle_pos), .B(paddle_pos_new), .sel(frame_clk_rising_edge));
    //mux2v #(10) pos_vel(.out(paddle_velocity_in), .A(paddle_velocity), .B(paddle_velocity_new), .sel(frame_clk_rising_edge));

    always @ (frame_clk_rising_edge) begin
        //by default, do nothing
        paddle_pos_new <= paddle_pos;
        //move up
        if (u_pressed && (paddle_pos > left_step_size)) begin
            paddle_pos_new <= paddle_pos - left_step_size;
        end
        if (d_pressed && (paddle_pos + left_step_size) <= paddle_max) begin
            paddle_pos_new <= paddle_pos + left_step_size;
        end
    end
endmodule
