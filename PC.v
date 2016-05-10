module PC(input [10:0] write_data_PC, output [10:0] read_PC, input print_regs, input CLK);
                                                                                    //CLK is control
	wire print_regs;  //syscall
	wire [10:0] write_data_PC;
	reg [10:0] read_PC;

	reg [2:0] PC3; //first 3 msb bits of address
	reg [7:0] PC8;  //bottom 8 bits of address


	//READ_PC
	always @ (posedge CLK) begin
		read_PC [10:8] <= PC3;
    	read_PC [7:0]  <= PC8;
		end


	//WRITE_PC 
	always @ (negedge CLK) begin
		PC3  <=  write_data_PC [10:8];
   		PC8 <= write_data_PC  [7:0];
		end 

	//PRINT THE PC REGS
	always @ (print_regs)
		if (print_regs==1) begin 
    		$strobe ("\n\n Decimal       Hex\n$PC3= %d       $PC3=%h\n$PC8= %d     $PC8=%2h", PC3, PC3, PC8, PC8);
    	end

endmodule 