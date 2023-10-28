module tt_um_clkdiv (
	// These are the required wire for gds, do not change
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset

);

// Clock Divider
reg [15:0] counter; // 16-bit register to hold the counter value
reg        div_clk;  // Divided clock signal

// Random Number Generator
reg [15:0] lfsr; // 16-bit LFSR

// Microcontroller
//wire [7:0] microcontroller_out;
//wire [7:0] microcontroller_control;
    
/*microcontroller mcu (
    .clk(clk),
    .rst(rst_n),
    .ena(ena),
    .uio_in(uio_in[7:0]),
	 .uio_out(microcontroller_out),
    .uio_oe(microcontroller_control)
);*/


// Clock Divider Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 16'd0;  // Reset the counter to 0 if the reset signal is low
        div_clk <= 0;      // Also set the divided clock to low
    end else if (ena) begin
        if (counter == {uio_in, ui_in}) begin
            counter <= 16'd0; // Reset the counter when it reaches the divide value
            div_clk <= ~div_clk; // Toggle the divided clock
        end else
            counter <= counter + 16'd1; // Increment the counter at each clock cycle
    end
end

// Random Number Generator Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr <= 16'h5555; // Reset the LFSR to some non-zero value
    end else if (ena) begin
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]}; // Feedback polynomial for 16-bit maximal length LFSR
    end
end

assign uio_oe = 8'b0; // Set all bits of uio_oe to 0 (input mode)
assign uo_out[0] = div_clk; // Assign the divided clock to the output
assign uo_out[7:1] = lfsr[9:3]; // Assign a subset of the random number to the output
	 
//assign uio_out[7:0] = microcontroller_out; 
//assign uio_oe[7:0] = microcontroller_control;

endmodule