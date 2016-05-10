module mux_Lwra (input [10:0] read_PC, input [10:0] read_data_stack, output [10:0] Lwramux_out, input Lwra);
	
	wire Lwra;  //control line
	wire [10:0] read_PC;
	wire [10:0] read_data_stack;
	reg [10:0] Lwramux_out;

	always @(*) begin

		if (Lwra==1) 
			Lwramux_out [10:0] <=  read_data_stack [10:0];
	
		else
			Lwramux_out [10:0] <= (read_PC [10:0] + 1'b1);
		end

endmodule 				