module ALU (input [2:0] ALUOp, input [7:0] ALU_input1, input [7:0] ALU_input2, output [7:0] ALU_result, output Zero, input get_int, input [7:0] int_wanted, input [4:0] opcode, input [15:0] instr, output FLAG_V);

	wire [2:0] ALUOp; //control line
	wire get_int;     //syscall
	wire [7:0] int_wanted;
	wire [4:0] opcode;
	wire [15:0] instr;

	wire signed [7:0] ALU_input1;  //inputs signed since twos complement, so can subtract by adding a negative
	wire signed [7:0] ALU_input2;
	reg signed [7:0] ALU_result;
	
	reg Zero;
	reg FLAG_V;        //addition over or under flow flag register
	

	always @(*) begin
		case (ALUOp)           //case switch statement based on ALUOp

			3'b000:    ALU_result =  ALU_input1 + ALU_input2;    //add

			3'b001: begin        //for beq

				if (ALU_input1-ALU_input2 == 0)   //if inputs are equal asset the Zero 
		    		Zero=1'b1;
				else  
					Zero=1'b0;                 //if not Zero is not asserted
			  		end

			3'b010: ALU_result= ALU_input1 ~& ALU_input2;       //bitwise nand

			3'b011: begin     //slt

				if (ALU_input1<ALU_input2) 
					ALU_result=8'b00000001;           
				else 
					ALU_result=8'b00000000;
		    		end

			3'b100:   ALU_result= ALU_input1 >> ALU_input2;    //srl
			3'bxxx:   
	      		if (opcode == 5'b11010 && instr [2:0] == 3'b010) begin    //redudant precaution: opcode already determined from ALUOp = 3'bxxx
	       			ALU_result [7:0] = int_wanted[7:0];                      //since ALU_result goes into $acc and trying to write the int_wanted into $acc
	       			end
			endcase
		end

	
	//OVER AND UNDER-FLOW FLAG
	always @ (*) 
		if (opcode [4:0] ==5'b00000 || opcode[4:0] ==5'b11101) begin    //only for add or addi commands

			if (ALU_input1 [7] == 1'b0 && ALU_input2 [7] == 1'b0 && ALU_result[7] == 1'b1) begin    //if add two positives and fet a negative answer
	    		FLAG_V =  1;
	 			$display ("FLAG_V = %b, ALU result overflow (see waveforms to confirm)" ,FLAG_V);
	 			end
	 		
	 		else if (ALU_input1[7] == 1'b1 && ALU_input2[7] ==1'b1 && ALU_result[7] == 1'b0) begin  //if add two negatives and get a positive answer
	  			FLAG_V =  1;
				$display ("FLAG_V = %b, ALU result underflow (see waveforms to confirm)" ,FLAG_V);
	 			end
			
			else begin
	 	 		FLAG_V=0;
	 		 	end

	 		end

		else begin     //if not add or addi don't send up a flag for anything
	 	 	FLAG_V=0;
	 		end

endmodule