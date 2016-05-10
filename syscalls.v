module syscalls (input [15:0] instr, input Syscalls, output print_acc, output print_regs, output get_int, output print_string, output print_stack);

  //takes in the instruction and Syscall assert or deasset and outputs all the specific syscall control lines

  reg print_acc; //print int in accumulator
  reg get_int;   //put an int from .data section of memory into the acc       
  reg print_regs;  //prints out all the registers (addressable and non-addressable)     
  reg print_string;  //print a string from the .data section of memory
  reg print_stack;   //prints out the stack from the top until encounter an unknown x, with exception that the top (0xFF)
                      //of the stack can be unknown x

  always @ (*) begin
    if (Syscalls==1 && instr [2:0]==3'b010)   // jrra 010
      get_int=1;
    else 
      get_int=0;
    end

  always @ (*) begin
    if (Syscalls==1 && instr [2:0]==3'b100)  //jrra 100
      print_acc = 1;
    else 
      print_acc = 0;
    end

  always @ (*) begin
    if (Syscalls==1 && instr [2:0]==3'b101)  //jrra 101
      print_regs =1;
    else 
      print_regs =0;
    end

  always @ (*) begin
    if (Syscalls==1 && instr [2:0]==3'b001)  //jrra 001
      print_string =1;
    else 
      print_string =0;
    end

  always @ (*) begin
    if (Syscalls==1 && instr [2:0]==3'b110)  //jrra 110
      print_stack =1;
    else 
      print_stack =0;
    end

endmodule

