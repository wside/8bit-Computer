// Matt Ferraria, Wendy Ide, Izzie Rong
// May 9, 216
//This is the 8bit computer parent module. All child modules on same level.
// ECE-151 Computer Archetecture, Professor Marano


`timescale 1ns/1ps   // **timescale in ns, so on waveform viewer zoom out**

`include "PC.v"
`include "instrmem.v"
`include "control.v"
`include "regfile.v"                   
`include "ALU.v"  
`include "stack.v"
`include "accumulator.v"                    //include all child module files
`include "accbuf.v"
`include "ra3.v"
`include "muxes_rf_reads.v"
`include "muxes_rf_writes.v"
`include "mux_ALUSrc.v"
`include "mux_Lwra.v"
`include "mux_stack.v"
`include "mux_PC.v"
`include "syscalls.v"


module eight_bit_computer ();  //start of the 8bit computer parent module 

	wire [10:0] read_PC;   //turns into read_PC_controlable
	wire [15:0] instr;
	wire [4:0] opcode ;       //control stuff
	wire [1:0] PCSrc;
	wire RegDst1, RegDst2;
	wire [1:0] ALUSrc; 
	wire AccWrite, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jal, Lwra, Syscalls, Zero;
	wire [2:0] ALUOp;
	wire signed [7:0] read_data1;     //data inside the registers comes out 
	wire signed [7:0] read_data2;
  	wire [7:0] read_data3;             
    wire  [2:0] read_reg1;          //muxes choosing which registers to read and from where
	wire [2:0] read_reg2;
	wire [2:0] read_reg3;
    wire [7:0] stackmux_out;     // muxes choosing which registers to write and from where
	wire [10:0] Lwramux_out;
	wire [10:0] read_data_stack; 
	wire [2:0] write_reg;
	wire signed [7:0] write_data;
	wire [2:0] write_data_ra3;

	trior signed [7:0] ALU_input1;   //mux for choosing ALU sources
	trior signed [7:0] ALU_input2;
	wire signed [7:0] read_data_accbuf;
	wire signed [7:0] ALU_result;      //ALU execute
	wire signed [10:0] write_data_stack;//stack stuff
	
	wire signed [7:0] read_data_acc;  //accumulator 
  
	wire [2:0] read_data_ra3; 
	wire [10:0] read_PC_controlable;   //this is what chooses which intruction
	wire [10:0] write_data_PC;        //what gets written to PC
	wire signed [10:0] beq_concat;                 
	wire print_acc, print_regs, get_int, print_string, print_stack; //syscall wires
	wire signed [7:0] int_wanted;
	wire FLAG_V, FLAG_T;   //flag wires
	wire [7:0] test;

	reg CLK;    //CLOCK DECLARED HERE

	always #1 CLK = ~CLK;   //CLOCK CYCLE TIME DECLARED HERE 

	//START THE SIMULATION
	initial begin   
		$dumpfile("8bit.vcd");  //creates the waveform file
         	$dumpvars(0,eight_bit_computer);

    	#0   CLK=0;       //initialize CLK at 0

    	//can uncomment bellow $monitor if want to see control line outputs at each instruction
 		//$monitor (" instr = %16b, opcode=%5b, PCSrc=%2b,  RegDst1=%b, RegDst2=%b, ALUSrc=%b, AccWrite=%2b ,\n MemtoReg=%b, ALUOp=%3b, RegWrite=%b, MemRead=%b, MemWrite=%b, Branch=%b, Jal=%b, Lwra=%b, Syscalls=%b\n\n", instr,opcode, PCSrc,
		//RegDst1,RegDst2,ALUSrc, AccWrite,MemtoReg,ALUOp,RegWrite,MemRead,MemWrite,Branch,Jal,Lwra,Syscalls);
 		end	


	//ENDS THE SIMULATION
	always @(opcode or instr)  
		if (opcode == 5'b11010 && instr [2:0] == 3'b000) begin  //if jrra 000 which is the finish command
			$display ("\n\n");
			$display($time, " ns = Time Elapsed") ;   //prints out the time elapsed
			$finish;                                  //EXIT FROM THE SIMULATION 
			end


	//instantiate child modules (16 total) below

	instrmem fetch (read_PC, instr, read_PC_controlable, read_data_accbuf , get_int, int_wanted, print_string, FLAG_T);  //get the instruction from memory //flag if run away simulation

	control get_ctrl_lines (instr, PCSrc, RegDst1, RegDst2, ALUSrc,                //output control line values
	                 AccWrite, MemtoReg, ALUOp, RegWrite, MemRead, MemWrite,
	                 Branch, Jal, Lwra, Syscalls, opcode, Zero);

	muxes_rf_reads instrdecode1 (instr, read_reg1, read_reg2, RegDst1, RegDst2);   //chose which regs to read

	muxes_rf_writes instrdecode2 (instr, read_data_stack, Lwramux_out, stackmux_out,   //chose which regs to write and what to write
	write_reg, write_data, write_data_ra3, Jal, opcode);

	assign read_reg3 [2:0] = instr [10:8]; //since read reg3 will only be instr [10:8] (for beq)

	regfile accessregs (RegWrite, write_reg, write_data,                                         //read data from selected registers 
	               read_reg1, read_data1, read_reg2, read_data2, read_reg3, read_data3, print_regs);     //or write to selected reg
 

	mux_ALUSrc instrdecode3 (read_data1, read_data2, read_data_accbuf,        //choose the sources of the two ALU inputs
	                       instr, ALU_input1, ALU_input2, ALUSrc);

	ALU execute (ALUOp, ALU_input1, ALU_input2, ALU_result, Zero, get_int,int_wanted, opcode, instr, FLAG_V); //ALU operation //flag is ALU result over or under_flow

	ra3 tie_to_ra8 (write_data_ra3, read_data_ra3, Jal, print_regs);  //$ra3 does what $ra8 does

	assign write_data_stack [10:0] = {read_data_ra3 [2:0], read_data1 [7:0]}; //always write $ra3 into 3 msb of 11 bit line of stack since only really care about lower 8 bits most of the time except when lw $ra8 which also loads $ra3 with 3 msb

	stack memaccess (ALU_result, write_data_stack, read_data_stack, MemWrite, MemRead, print_stack); //sw or lw to or from the stack

	acc accumulatorRW (ALU_result, read_data_acc, AccWrite, print_acc, print_regs, opcode, Syscalls, instr); //read from or write to $acc
	accbuf accbufRW (read_data_acc, read_data_accbuf, CLK);

	mux_stack writeback (read_data_stack, read_data_accbuf, stackmux_out, MemtoReg);  //mux for what gets written into a selected reg

	mux_Lwra special(read_PC_controlable, read_data_stack, Lwramux_out, Lwra); //if lw $ra write data is PC+1 not stackmux_out

	mux_PC choosePCSrc (read_PC_controlable, instr, read_data1, read_data3, //choose PC source (PC+1, beq, jrra, or jal)
	read_data_ra3, write_data_PC, PCSrc);

	PC get_next_instr (write_data_PC, read_PC, print_regs, CLK); //advance PC 

	syscalls implememnt (instr, Syscalls, print_acc, print_regs, get_int, print_string, print_stack); //printing and stuff 

endmodule  //end of the 8bit computer parent module