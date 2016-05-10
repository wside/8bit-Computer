module stack( input [7:0] address, input [10:0] write_data_stack, output [10:0] read_data_stack, 
	input MemWrite, input MemRead, input print_stack);          

	wire MemWrite, MemRead; //control lines
  wire print_stack;      //syscall
	wire [7:0] address;   //stack address in unsigned (since cannot be negative)
  
	wire signed [10:0] write_data_stack;
	reg signed [10:0] read_data_stack;
  reg FLAG_S;
  reg [7:0] j;

	reg signed [10:0] stack [0:255];     //STACK is declared here //data inside stack is signed

 
	// READ_STACK
	always @ (*)
    	if (MemWrite==0 && MemRead==1)  begin
         	read_data_stack <= stack[address];
    		end

	//WRITE_STACK
	always @ (*)
   		if ( MemWrite==1 && MemRead==0) begin
       		stack[address] <= write_data_stack;
   			end

  //Do nothing			
  always @ (*)
    if (MemWrite==0 && MemRead==0)  begin
      read_data_stack <= 11'bx;
    	end

   //PRINT STACK
  always @(print_stack) 
   
    if (print_stack==1) begin
      
      $write ("\n            STACK     \n-------------------------------------\nLine (dec, hex)    Data (dec, hex)    \n");
      $write (" 255,  ff            %d,  %h\n", stack['d255] [7:0], stack['d255] [7:0]);  //in case data in 0xFF is xx 
      
        for (j=254; stack[j] [10:0] != 8'bx; j=j-1) begin
          $write (" %d,  %h            %d,  %h\n", j, j, stack[j] [7:0], stack[j] [7:0]) ;  //print until encounter an unknown
          end
          
      end

endmodule