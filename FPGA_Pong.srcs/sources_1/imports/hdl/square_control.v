module square_control(output is_square, input clk, input reset, input [9:0] draw_x, input [9:0] draw_y, input frame_clk,
    input start_left, input start_right, input hit_left_paddle, input hit_right_paddle,
    output [9:0] square_x_center, output [9:0] square_y_center);

    `include "game_param.vh"

    //coordinate of center
    reg [9:0] square_pos_x, square_vel_x;
    reg [9:0] square_pos_y, square_vel_y;

    assign square_x_center = square_pos_x;
    assign square_y_center = square_pos_y;

    //frame clock temp registers
    reg [9:0] square_pos_x_in, square_vel_x_in;
    reg [9:0] square_pos_y_in, square_vel_y_in;

    reg [7:0] hit_count = 8'b0;
    wire [9:0] hit_count_div_four = {4'b0, hit_count[7:2]};
    wire x_vel_negative_flag = square_vel_x[9];
    assign paddle_hit = hit_count;

    reg frame_clk_delayed, frame_clk_rising_edge;
    reg round_start_mark = 1'b0;

    always @ (posedge clk or posedge reset) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
        if (reset) begin
            frame_clk_delayed <= 1'b0;
            frame_clk_rising_edge <= 1'b0;
            square_pos_x <= center_x;
            square_pos_y <= center_y;
            square_vel_x <= 10'd0;
            square_vel_y <= 10'd0;
        end else begin
            if (frame_clk_rising_edge) begin
                square_pos_x <= square_pos_x_in;
                square_pos_y <= square_pos_y_in;
                square_vel_x <= square_vel_x_in;
                square_vel_y <= square_vel_y_in;
            end else begin
                //keep position and velocity registers unchanged.
            end
        end
    end

    wire in_x_bound = (draw_x < (square_pos_x + square_half_width)) & ((draw_x + square_half_width) > square_pos_x);
    wire in_y_bound = (draw_y < (square_pos_y + square_half_width)) & ((draw_y + square_half_width) > square_pos_y);
    assign is_square = in_x_bound & in_y_bound;

    wire [9:0] inverse_y_vel = (~(square_vel_y) + 1'b1);

    reg y_minus_mark = 1'b0;

    wire collision_override_mark;
    reg collision_resolved = 1'b0; //no collision from the beginning
    dffe paddle_square_collision(.q(collision_override_mark), .d(1'b1), .clk(hit_left_paddle | hit_right_paddle), .enable(1'b1), .reset(collision_resolved));

    wire [9:0] true_init_x_vel = init_x_velocity;
    wire [9:0] new_collision_vel_from_neg = true_init_x_vel + hit_count_div_four;
    wire [9:0] new_collision_vel_from_pos = (~(new_collision_vel_from_neg) + 1'b1);

    always @ (posedge frame_clk or posedge reset) begin
        //by default, keep velocity and update location
        square_vel_x_in <= square_vel_x;
        square_vel_y_in <= square_vel_y;
        square_pos_x_in <= square_pos_x + square_vel_x;
        collision_resolved <= 1'b0;
        if (y_minus_mark)
            square_pos_y_in <= square_pos_y + inverse_y_vel;
        else
            square_pos_y_in <= square_pos_y + square_vel_y;
        //game hasn't started
        if (round_start_mark) begin
            if (square_pos_y + square_vel_y > 10'd480) begin
                //traveling out of lower bound, bounce!
                y_minus_mark <= 1'b1;
            end
            if (square_pos_y < square_vel_y) begin
                y_minus_mark <= 1'b0;
            end
            if (collision_override_mark) begin
                if (x_vel_negative_flag)
                    square_vel_x_in <= new_collision_vel_from_neg;
                else
                    square_vel_x_in <= new_collision_vel_from_pos;
                square_pos_x_in <= square_pos_x + (~(square_vel_x + 10'd3) + 1'b1);
                //y_minus_mark <= ~y_minus_mark;
                collision_resolved <= 1'b1;
                hit_count <= hit_count + 1'b1;
            end
        end else begin
            if (start_left) begin
                square_vel_x_in <= (~(init_x_velocity) + 1'b1);
                square_vel_y_in <= init_y_velocity;
                round_start_mark <= 1'b1;
            end else begin
                if (start_right) begin
                    square_vel_x_in <= init_x_velocity;
                    square_vel_y_in <= init_y_velocity;
                    round_start_mark <= 1'b1;
                end
            end
        end
        if (reset) begin
            round_start_mark <= 1'b0;
            hit_count <= 8'b0;
            square_vel_x_in <= 10'b0;
            square_vel_y_in <= 10'b0;
            square_pos_x_in <= center_x;
            square_pos_y_in <= center_y;
        end
    end
endmodule
