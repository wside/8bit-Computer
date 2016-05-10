module mux_ALUSrc (input [7:0] read_data1, input [7:0] read_data2, input [7:0] read_data_accbuf, 
	input [15:0] instr, output [7:0] ALU_input1, output [7:0] ALU_input2, input [1:0]  ALUSrc);
	
	wire [1:0]  ALUSrc;     //control line 
	wire signed [7:0] read_data1;
	wire signed [7:0] read_data2;
	wire signed [7:0] read_data_accbuf;
	
	
	wire [15:0] instr;
	reg signed [7:0] offset_ext ;
	reg signed [7:0] srl_numbits_ext;
	trior signed [7:0] ALU_input1;
	trior signed [7:0] ALU_input2;

	reg enable0, enable1, enable2, enable3;  //for the tristate buffers 


	always @* begin
		offset_ext [7:0] = {{3{instr [12]}}, instr [12:8]};   //sign extension offset from base reg (for sw and lw commands)
		srl_numbits_ext [7:0]= {5'b000, instr [2:0]};         //srl numbits is unsigned positive 3 bit int so just zero extend
		end

	always @* begin
		if (ALUSrc ==2'b00) begin          //have to be extremely explicit about enables so tristate bufs know what to do at any case
			enable0=1;
			enable1=0;
			enable2=0;
			enable3=0;
			end
		else if (ALUSrc ==2'b01) begin
			enable0=0;
			enable1=1;
			enable2=0;
			enable3=0;
			end	
		else if (ALUSrc==2'b10) begin
			enable0=0;
			enable1=0;
			enable2=1;
			enable3=0;
			end
		else if(ALUSrc ==2'b11) begin
			enable0=0;
			enable1=0;
			enable2=0;
			enable3=1;
			end
		end
	

	assign  ALU_input1  = (enable0) ? read_data1 : 8'bz;                
	assign  ALU_input2  = (enable0) ? read_data2 : 8'bz;
				
			
	assign  ALU_input1  = (enable1) ? read_data_accbuf : 8'bz;   //not really a mux
	assign  ALU_input2  = (enable1) ? srl_numbits_ext : 8'bz;    //ALU sources are chosen with tristate buffers then all 
				                                                 //OR'd together with the trior type net
			                                                     //like this because can't put assign statements inside always blocks
	assign  ALU_input1  = (enable2) ? read_data1 [7:0]: 8'bz;    //With the "assign" statements can apply delays if wanted
	assign  ALU_input2 = (enable2) ? instr [15:8]: 8'bz;
				
			
	assign  ALU_input1 = (enable3) ? read_data2 : 8'bz;
	assign  ALU_input2 = (enable3) ? offset_ext : 8'bz;
		

endmodule 

