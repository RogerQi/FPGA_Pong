module color_renderer(output reg [3:0] red, output reg [3:0] green, output reg [3:0] blue,
    input is_paddle, input is_square, input [9:0] draw_x, input [9:0] draw_y, input clk);

    localparam HPERIOD = 10'd800;
    localparam HFRONT  = 10'd16;
    localparam HWIDTH  = 10'd96;
    localparam HBACK   = 10'd48;

    localparam VPERIOD = 10'd525;
    localparam VFRONT  = 10'd10;
    localparam VWIDTH  = 10'd2;
    localparam VBACK   = 10'd33;

    localparam HSIZE = 10'd80;
    localparam VSIZE = 10'd120;

    wire [9:0] HBLANK = HFRONT + HWIDTH + HBACK;
    wire [9:0] VBLANK = VFRONT + VWIDTH + VBACK;

    wire disp_enable = (VBLANK <= draw_y) && (HBLANK-10'd1 <= draw_x) && (draw_x < HPERIOD-10'd1);

    wire [2:0] rgb_0 = (draw_x-HBLANK+10'd1)/HSIZE;
    wire [2:0] rgb_1 = (((draw_y-VBLANK)/VSIZE)&1)==0 ? 3'd7-rgb_0: rgb_0;

    wire is_background = ~(is_paddle | is_square);
    //x: [160:800]
    //y: [45:525]
    always @ (posedge clk) begin
        if (disp_enable) begin
            if (is_background) begin
                //background
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b1000;
            end else begin
                //it's some entities
                if (is_square) begin
                    red <= 4'b1111; //test
                    green <= 4'b0; //test
                    blue <= 4'b0; //test
                end
                if (is_paddle) begin
                    red <= 4'b1111; //test
                    green <= 4'b1111; //test
                    blue <= 4'b1111; //test
                end
            end
        end else begin
            //ensure correct output; No color signals in blanking (relocating).
            red <= 4'b0000; //test
            green <= 4'b0000; //test
            blue <= 4'b0000; //test
        end
    end

    /*
    //paddle is white
    wire [3:0] paddle_red = 4'b1111;
    wire [3:0] paddle_green = 4'b1111;
    wire [3:0] paddle_blue = 4'b1111;

    //by default, background is black
    wire [3:0] bg_red = 4'b0000;
    wire [3:0] bg_green = 4'b0000;
    wire [3:0] bg_blue = 4'b0000;

    mux2v #(4) red_mux(.out(red), .A(bg_red), .B(paddle_red), .sel(is_paddle));
    mux2v #(4) green_mux(.out(green), .A(bg_green), .B(paddle_green), .sel(is_paddle));
    mux2v #(4) blue_mux(.out(blue), .A(bg_blue), .B(paddle_blue), .sel(is_paddle));*/
endmodule
