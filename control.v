module control
	(input [15:0] instr,   //the control takes in the full instruction...
	output [1:0] PCSrc,
	output RegDst1,
	output RegDst2,
	output [1:0] ALUSrc, 
	output AccWrite,
	output MemtoReg,
	output [2:0] ALUOp,      //and outputs all the control lines
	output RegWrite,
	output MemRead,
	output MemWrite,
	output Branch,
	output Jal,
	output Lwra,
	output Syscalls,
	output [4:0] opcode,
	input Zero);           //to determine if beq branches or not (important for PCSrc cntrl line)

	reg [4:0] opcode ;
	reg [1:0] PCSrc;
	reg RegDst1;
	reg RegDst2;
	reg [1:0] ALUSrc; 
	reg AccWrite;
	reg MemtoReg;
	reg [2:0] ALUOp;
	reg RegWrite;
	reg MemRead;
	reg MemWrite;
	reg Branch;
	reg Jal;
	reg Lwra;
	reg Syscalls;
	wire Zero;
	wire [15:0] instr;

	always @ (*) begin   //start by determining the opcode
		
		if (instr [7:6] == 2'b11)       //if the two msb of low byte are 11, it's a two line instr and
			opcode [4:0] = instr [7:3];   //opcode is the five msb of low byte   
		
		else if (instr [7:6] != 2'b11)           //if the two msb of low byte are not  11, it's a one line instr and
			opcode [4:0] = {instr[7:6],3'b000};	 //opcode is the two msb of low byte followed by three 0's, keeps uniform opcode length of 5 bits
		end


	always @ (*) begin
		case (opcode [4:0])   //case switch statement based on opcode
		
			5'b00000:    //add
	    		
	    		begin
					PCSrc<=2'b00;   RegDst1<=0;      RegDst2<=0;      ALUSrc<=2'b00;   AccWrite<=1;   ALUOp<=3'b000; Syscalls <=0; 	
					end		
			
			5'b01000:     //nand
				
				begin
					PCSrc<=2'b00;   RegDst1<=0;      RegDst2<=0;      ALUSrc<=2'b00;   AccWrite<=1;   ALUOp<=3'b010; Syscalls <=0; 
					end
			
			5'b10000:     //slt
				
				begin
					PCSrc<=2'b00;   RegDst1<=0;      RegDst2<=0;      ALUSrc<=2'b00;   AccWrite<=1;   ALUOp<=3'b011; Syscalls <=0; 
					end	
		
			5'b11000:   //move
				
				begin
				 	PCSrc<=2'b00;   RegDst1<=1'bx;   RegDst2<=1'bx;   ALUSrc<=2'bxx;   AccWrite<=0;   ALUOp<=3'b101; Syscalls <=0; 
					end	
			
			5'b11001:   //srl
				
				begin
					PCSrc<=2'b00;   RegDst1<=1'bx;   RegDst2<=1'bx;   ALUSrc<=2'b01;   AccWrite<=1;   ALUOp<=3'b100; Syscalls <=0; 
					end	
			
			5'b11010:   
				
				if (instr [2:0] == 3'b011) begin    //jrra
					Syscalls <=0; 
					PCSrc<=2'b10;   RegDst1<=1;      RegDst2<=1'bx;   ALUSrc<=2'bxx;   AccWrite<=0;   ALUOp<=3'b101;
					end	
				else if (instr [2:0] == 3'b010) begin     //jr somethingelse = syscall
					Syscalls <=1; 
					PCSrc<=2'b00;   RegDst1<=1'bx;      RegDst2<=1'bx;   ALUSrc<=2'bxx;   AccWrite<=1;   ALUOp<=3'bxxx;
					end
				else if (instr [2:0] != 3'b011 && instr [2:0] != 3'b010) begin
					Syscalls <=1; 
					PCSrc<=2'b00;   RegDst1<=1'bx;      RegDst2<=1'bx;   ALUSrc<=2'bxx;   AccWrite<=0;   ALUOp<=3'bxxx;
					end
			
			5'b11011:   //jal
				
				begin
					PCSrc<=2'b11;   RegDst1<=1'bx;   RegDst2<=1'bx;   ALUSrc<=2'bxx;   AccWrite<=0;   ALUOp<=3'b101; Syscalls <=0; 
					end	
			
			5'b11100:   //sw
				
				begin
					PCSrc<=2'b00;   RegDst1<=1;      RegDst2<=1;      ALUSrc<=2'b11;   AccWrite<=0;   ALUOp<=3'b000; Syscalls <=0; 
					end	
			
			5'b11101:   //addi
				
				begin
					PCSrc<=2'b00;   RegDst1<=1;      RegDst2<=1'bx;   ALUSrc<=2'b10;   AccWrite<=1;   ALUOp<=3'b000; Syscalls <=0; 
					end	 
			
			5'b11110:     //lw
				
				begin
					PCSrc<=2'b00;   RegDst1<=1'bx;   RegDst2<=1;      ALUSrc<=2'b11;   AccWrite<=0;   ALUOp<=3'b000; Syscalls <=0; 
					end	
			
			5'b11111:    //beq
				
				if (Zero == 1) begin
					PCSrc<=2'b01;   RegDst1<=1;      RegDst2<=1;      ALUSrc<=2'b00;   AccWrite<=0;   ALUOp<=3'b001; Syscalls <=0; 
					end
				else begin
					PCSrc<=2'b00;   RegDst1<=1;      RegDst2<=1;      ALUSrc<=2'b00;   AccWrite<=0;   ALUOp<=3'b001; Syscalls <=0; 
					end 
				endcase 
		end


	always @ (*) 
		if (opcode[4:0]==5'b11011) begin     //if jal
			Jal <= 1;
			end
		else if (opcode[4:0]==5'b11110 && instr [2:0] == 3'b011) begin    //if lw and reg is $ra
			Jal <=1;
			end
		else begin 
			Jal <=0;
			end

	always @ (*) begin
		if (opcode[4:0]==5'b11111 )   //if beq
			 Branch <= 1;
		else 
			Branch<=0;
			end

	always @ (*) begin
		if (opcode[4:0]==5'b11100)    //if sw
			MemWrite <= 1;
		else  
			MemWrite <=0;
			end
	
	always @ (*) begin
		if (opcode[4:0]==5'b11110 && instr [2:0] == 3'b011)    //if lw and reg is $ra
			Lwra <=1;
		else  
			Lwra <=0;
		end

	always @ (*) 
		if (opcode [4:0]==5'b11000)  begin   //if move  
			RegWrite <= 1;
			MemtoReg <= 1;
			MemRead <= 0;
			end
		else if (opcode[4:0]==5'b11110)  begin  //if lw
		 	RegWrite <= 1;
		 	MemtoReg <= 0;
		 	MemRead <= 1;
		 	end
		 else if (opcode[4:0]==5'b11011)  begin  //if jal need to wright next address llower 8 bits into $ra8
		 	RegWrite <= 1;
		 	MemtoReg <= 1'bx;
		 	MemRead <= 0;
		 	end
		else begin
			RegWrite <= 0;
			MemRead <= 0;
			MemtoReg <= 1'bx;
		end


endmodule
