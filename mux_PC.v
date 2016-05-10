module mux_PC (input [10:0] read_PC,input [15:0] instr, input [7:0] read_data1, input [7:0] read_data3, 
	input [2:0] read_data_ra3,  output [10:0] write_data_PC, input [1:0] PCSrc); 
	
	wire [1:0] PCSrc; //control line
	wire [10:0] read_PC;
	wire [15:0] instr;
	wire [7:0] read_data1;
	wire [7:0] read_data3;
	wire [2:0] read_data_ra3;
	
	reg  [10:0] write_data_PC;   //output what gets written to the PC 
	reg signed [10:0] beq_concat ;
	reg [10:0] jrra_concat ;
	reg [10:0] jal_concat ;

	always @ (*) begin
		beq_concat [10:0] = {instr[12], instr [12:11], read_data3 [7:0]};
		jrra_concat [10:0] = { read_data_ra3 [2:0],  read_data1 [7:0]};
		jal_concat [10:0] = { instr [2:0],  instr [15:8]};
	end

	always @ (*) begin
		case (PCSrc [1:0])
			2'b00:  begin
				write_data_PC [10:0] <= (read_PC [10:0] + 1'b1);          //PC+1
				end
			2'b01:  begin 
				 write_data_PC [10:0] <= (read_PC [10:0]+ beq_concat [10:0]);     //beq
			     end
			2'b10:  begin
			 	 write_data_PC [10:0] <= jrra_concat [10:0];        //jrra
				 end
			2'b11:  begin
				write_data_PC [10:0] <= jal_concat [10:0];          //jal
				end
			endcase
		end






endmodule 