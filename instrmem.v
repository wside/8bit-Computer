module instrmem (input [10:0] read_PC , output [15:0] instr, output [10:0] read_PC_controlable, input [7:0] read_data_acc_buf, input get_int, output [7:0] int_wanted, input print_string, output FLAG_T);
	
	wire get_int;  //syscall
	wire print_string;  //syscall
	reg FLAG_T;      //termination flag
	
	wire [10:0] read_PC;   //determines what the next instruction will be
	wire [15:0] instr;     //the instruction!
	wire [7:0] read_data_acc_buf;
	
	reg enable;   //lets the instruction through the buffer or not
	reg [10:0] read_PC_controlable;

	reg [15:0]  instrmem[0:2047];        //INSTRUCTION MEMORY declared here 

	reg [10:0] int_addr;
	reg [15:0] int_full_line;
	reg signed [7:0] int_wanted;
	reg [10:0] string_addr;

	reg [10:0] i; //for print string loops 
	reg k;

	always @ (*) begin
		read_PC_controlable = read_PC;    //turn read_PC into a reg so can initialze it
		end

	initial begin
    
    	#0 $readmemb("instrmem.list", instrmem);
    
		#1	enable=1;

 		read_PC_controlable = 11'b00100000000;   //initialize PC at address line 256

    	end
      
	
	assign  instr  = (enable) ? instrmem[read_PC_controlable] : 16'bz;   //put the instr through a buffer


	always @(get_int)                               
		if (get_int==1) begin
			int_addr [10:0]= {3'b0, read_data_acc_buf [7:0]};         
			int_full_line [15:0] =instrmem[int_addr];
			int_wanted [7:0] = int_full_line [7:0];                     //get the int from .data section you want
			end                                                         //int is always in the low byte of the line

	always @(print_string) 

		if (print_string==1) begin

			string_addr [10:0]= {3'b0, read_data_acc_buf [7:0]};       //strings always begin on high bytes

			i = string_addr;
			k=0;

				while (instrmem[i] [15:8] != 8'b0 && k!=1) begin             //if the next line doesn't start with a null...

					if (instrmem[i] [15:8] != 8'b0) begin          //print the high byte if not null
						$write ("%c", instrmem[i] [15:8]);
						end
					if (instrmem[i] [7:0] != 8'b0 ) begin          //print the low byte if not null
					$write ("%c", instrmem[i] [7:0]);
					end
					else begin 
					k=1;
						end

					i = i+1'b1;                                   // i++                 
					end
			end

	//PREVENT RUN-AWAY SIMULATION
	always @ (read_PC_controlable or instr) 

    	if (read_PC_controlable >=  11'b00100000000 && instr === 16'bxxxxxxxxxxxxxxxx) begin  //if instr is unknown and PC is >= 0x100
        
        FLAG_T = 1;
    	
    	$display ("\nFLAG_T = %b: Instr Memory Addr %h is out of bounds or data is unknown (code possibly missing finish command)\n\nTerminating program!", FLAG_T, read_PC_controlable);
   
    	#1	 $finish;

   		end

endmodule



	

