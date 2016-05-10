module mux_stack (input [10:0] read_data_stack, input [7:0] read_data_accbuf, output [7:0] stackmux_out, input MemtoReg);

	wire [10:0] read_data_stack; 
	wire signed [7:0] read_data_accbuf; 
	trior signed [7:0] stackmux_out; 
	reg enable0, enable1; //for tristate buffer

	always @* begin
		if (MemtoReg == 0) begin
			enable0=1;
			enable1=0;
			end
		else if (MemtoReg == 1) begin
			enable0=0;
			enable1=1;	
			end
		end

	//like mux_ALU, mux_stack is not really a mux, but tristate buffer
	//like this so can add delays if want

	assign stackmux_out  = (enable0) ? read_data_stack [7:0] : 8'bz;    //lw or lwra
	assign stackmux_out  = (enable1) ? read_data_accbuf [7:0] : 8'bz;   //move from acc 

endmodule