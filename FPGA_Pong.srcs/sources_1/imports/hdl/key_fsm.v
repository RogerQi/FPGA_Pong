module key_fsm(output key_pressed, input [15:0] keycode, input clk, input reset);
    parameter
        desired_key_id = 8'h1d;

    reg s_non_pressed = 1'b1; //inited to be 1
    reg s_pressed;

    wire [7:0] desired_main_code = desired_key_id; //hardcoded to assigned value
    wire [15:0] lift_key_code = {8'hF0, desired_main_code};

    wire true_press_key = ~(keycode[15:8] == 8'hF0) & (keycode[7:0] == desired_main_code);
    wire lifted = (keycode == lift_key_code);
    //wire s_non_pressed_next = reset | (lifted & s_pressed) | (~true_press_key & s_non_pressed);
    wire s_pressed_next = ~reset & ((~lifted & s_pressed) | (true_press_key & s_non_pressed));
    wire s_non_pressed_next = ~s_pressed_next;

    always @ (posedge clk) begin
        s_non_pressed <= s_non_pressed_next;
        s_pressed <= s_pressed_next;
    end

    assign key_pressed = s_pressed;
endmodule
