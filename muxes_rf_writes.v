module muxes_rf_writes (input [15:0] instr, input [10:0] read_data_stack, input [10:0] Lwramux_out, input [7:0] stackmux_out,
	output [2:0] write_reg, output [7:0] write_data, output [2:0] write_data_ra3, input Jal, input [4:0] opcode);
	
	wire Jal;    //control line
	wire [4:0] opcode;
	wire [7:0] stackmux_out;
	wire [10:0] Lwramux_out;
	wire [10:0] read_data_stack; 
	wire [15:0] instr;
	
	reg [2:0] write_reg;           //choose which reg to write to
	reg signed [7:0] write_data;   //outputs the write_data
	reg [2:0] write_data_ra3;


	always @(*) 

		if (Jal==1) begin
			write_data [7:0] <= Lwramux_out [7:0];
			write_data_ra3 [2:0] <= Lwramux_out [10:8];
			end

		else begin
			write_data [7:0] <= stackmux_out [7:0];
			write_data_ra3 [2:0] <= read_data_stack [10:8];
			end


	always @(*)

		if (opcode[4:0]==5'b11011)  begin    //condition is opcode here istead of Jal because Jal is also high for lw $ra. Doesn't actually matter for lw $ra since $ra is reg 011										//but matters for plain Jal command because of timing
			write_reg [2:0] <= 3'b011;
			end

		else begin 
			write_reg [2:0] <= instr [2:0];
			end

endmodule
