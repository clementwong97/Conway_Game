module main (reset_key, sysclk, column_driver, row_sink);

	input reset_key;
	input sysclk;
	output logic [7:0] column_driver, row_sink;
	parameter X = 7, Y = 7;
	
	//Determines whether a square is on or off
	wire [0:X][0:Y] cells;
	
	wire [0:X][0:Y] cells_reset_state;
	
	//Initialising the grid
	logic [0:X][0:Y] grid = {	8'b00011000,
										8'b00111100,
										8'b01011010,
										8'b10011001,
										8'b00011000,
										8'b00011000,
										8'b00011000,
										8'b00011000};

	logic [2:0] count = 3'd0;
	
	//Preset state is the same as the initialisation grid
	assign cells_reset_state = grid;
	
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
	
	genvar i, j;
	generate
		for (i = 0; i < 8; i++) begin : X_AXIS
				for (j = 0; j < 8; j++) begin : Y_AXIS
					
					wire [7:0] neighbours;
					if ((i == 0) && (j == 0)) begin
						//top-left corner
						assign neighbours[0] = grid [i][j + 1];
						assign neighbours[1] = grid [i + 1][j];
						assign neighbours[2] = grid [i + 1][j + 1];
						assign neighbours[3] = 0;
						assign neighbours[4] = 0;
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if ((i == 0) && (j == 7)) begin
						//bottom-left corner
						assign neighbours[0] = grid [i][j - 1];
						assign neighbours[1] = grid [i + 1][j];
						assign neighbours[2] = grid [i + 1][j - 1];
						assign neighbours[3] = 0;
						assign neighbours[4] = 0;
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if ((i == 7) && (j == 0)) begin
						//top-right corner
						assign neighbours[0] = grid [i][j + 1];
						assign neighbours[1] = grid [i - 1][j];
						assign neighbours[2] = grid [i - 1][j + 1];
						assign neighbours[3] = 0;
						assign neighbours[4] = 0;
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if ((i == 7) && (j == 7)) begin
						//bottom-right corner
						assign neighbours[0] = grid [i][j - 1];
						assign neighbours[1] = grid [i - 1][j];
						assign neighbours[2] = grid [i - 1][j - 1];
						assign neighbours[3] = 0;
						assign neighbours[4] = 0;
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if (i == 0) begin
						//left edge
						assign neighbours[0] = grid [i][j - 1];
						assign neighbours[1] = grid [i][j + 1];
						assign neighbours[2] = grid [i + 1][j - 1];
						assign neighbours[3] = grid [i + 1][j];
						assign neighbours[4] = grid [i + 1][j + 1];
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if (i == 7) begin
						//right edge
						assign neighbours[0] = grid [i][j - 1];
						assign neighbours[1] = grid [i][j + 1];
						assign neighbours[2] = grid [i - 1][j - 1];
						assign neighbours[3] = grid [i - 1][j];
						assign neighbours[4] = grid [i - 1][j + 1];
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if (j == 0) begin
						//top edge
						assign neighbours[0] = grid [i - 1][j];
						assign neighbours[1] = grid [i + 1][j];
						assign neighbours[2] = grid [i - 1][j + 1];
						assign neighbours[3] = grid [i][j + 1];
						assign neighbours[4] = grid [i + 1][j + 1];
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else if (j == 7) begin
						//bottom edge
						assign neighbours[0] = grid [i - 1][j];
						assign neighbours[1] = grid [i + 1][j];
						assign neighbours[2] = grid [i - 1][j - 1];
						assign neighbours[3] = grid [i][j - 1];
						assign neighbours[4] = grid [i + 1][j - 1];
						assign neighbours[5] = 0;
						assign neighbours[6] = 0;
						assign neighbours[7] = 0;
						end
					else begin
						//middle squares
						assign neighbours[0] = grid [i][j + 1];
						assign neighbours[1] = grid [i][j - 1];
						assign neighbours[2] = grid [i - 1][j - 1];
						assign neighbours[3] = grid [i - 1][j];
						assign neighbours[4] = grid [i - 1][j + 1];
						assign neighbours[5] = grid [i + 1][j - 1];
						assign neighbours[6] = grid [i + 1][j];
						assign neighbours[7] = grid [i + 1][j + 1];
						end
					
					life_cell lc(neighbours, clk_1Mhz, reset_key, cells_reset_state[i][j], cells[i][j]);
				end
			end
		
		endgenerate 
		
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
		assign column_driver = cells[count];

		endmodule
		