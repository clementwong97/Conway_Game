module LEDdisplayTest(sysclk, column_driver, row_sink);
	input logic sysclk;
	output logic [7:0] column_driver, row_sink;
	logic [0:7][0:7] ROM1 = {	8'b00011000,
										8'b00111100,
										8'b01011010,
										8'b10011001,
										8'b00011000,
										8'b00011000,
										8'b00011000,
										8'b00011000};

	logic [2:0] count = 3'd0;

		// to generate a slower clock (1MHz)
		int clkdiv = 50000000/1000000/2;
		int sysclk_count=0;
		logic clk_1MHz = 0;

		always @ (posedge sysclk)
		begin
			if (sysclk_count == clkdiv) begin
				clk_1MHz = ~clk_1MHz;
				sysclk_count = 0;
			end
			else
				sysclk_count = sysclk_count + 1;
			end

		// counter to select rows in LED matrix
		always @(posedge clk_1MHz)
			count <= count + 3'b001;
		
		// row decorder (3-to-8 decoder)
		always @(*)
			case (count)
			3'b000: row_sink = 8'b11111110;
			3'b001: row_sink = 8'b11111101;
			3'b010: row_sink = 8'b11111011;
			3'b011: row_sink = 8'b11110111;
			3'b100: row_sink = 8'b11101111;
			3'b101: row_sink = 8'b11011111;
			3'b110: row_sink = 8'b10111111;
			3'b111: row_sink = 8'b01111111;
		endcase

		// sends data from the ROM to each row
		assign column_driver = ROM1[count];

		endmodule
