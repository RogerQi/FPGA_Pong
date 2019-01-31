//VGA params
localparam vga_width = 640;
localparam vga_height = 480;

//square params
localparam square_half_width = 10;
localparam square_horizontal_width = 10;
localparam square_vertical_width = 10;
localparam center_x = 320;
localparam center_y = 240;
localparam init_y_velocity = 3;
localparam init_x_velocity = 2; //if going right, add this. Otherwise minus this number.

//main(right) paddle params
localparam paddle_width = 10;
localparam paddle_height = 80;
localparam paddle_min = 0;
localparam x_max = 640;
localparam step_size = 2;

//left paddle params
localparam left_paddle_width = 10;
localparam left_paddle_height = 80;
localparam left_step_size = 2;