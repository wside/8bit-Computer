module muxes_rf_reads (input [15:0] instr, 
	output [2:0] read_reg1, 
	output [2:0] read_reg2, 
	input RegDst1, input RegDst2); 

	wire [15:0] instr;
	reg  [2:0] read_reg1;
	reg [2:0] read_reg2;
	wire RegDst1, RegDst2;   //control lines                                                             
	
	always @(*) begin
		if (RegDst1==1) 
			read_reg1 [2:0] <= instr [2:0];
			else
				read_reg1 [2:0] <= instr [5:3];
				end
	

	always @(*) begin
		if (RegDst2==1) 
			read_reg2 [2:0] <= instr [15:13];
			else 
				read_reg2 [2:0] <= instr [2:0];
				end 

endmodule
