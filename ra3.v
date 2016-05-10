module ra3(input [2:0] write_data_ra3, output [2:0] read_data_ra3, input Jal, input print_regs);
   
   wire AccWrite; //control line
	wire print_regs; //syscall
	wire [2:0] write_data_ra3;
	reg [2:0] read_data_ra3; 

	reg [2:0] ra3;  //$ra3 DECLARED HERE 


 	always @(*) begin

   		if (Jal==1)
   			ra3 [2:0] <= write_data_ra3 [2:0];    //if Jal wright to $ra3

   		else 
   			read_data_ra3 [2:0]  <= ra3 [2:0] ;   //else always read from $ra3
   			end

   //PRINT $ra3
   always @ (print_regs)
      if (print_regs==1) begin
         $strobe ("$ra3= %d       $ra3= %h", ra3, ra3);
         end

endmodule
 