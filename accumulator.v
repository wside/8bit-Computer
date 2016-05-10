module acc (input [7:0] write_data_acc, output [7:0] read_data_acc, input AccWrite, input print_acc, input print_regs, input [4:0] opcode, input Syscalls, input [15:0] instr);
  
  wire AccWrite; //control line
  
  wire print_acc;
  wire print_regs;

	wire signed [7:0] write_data_acc;
  wire signed [7:0] acc_absolute;
  
  reg signed [7:0] read_data_acc; 
  

	reg signed [7:0] acc;        //ACCUMULATOR declared here
  
  
  assign  acc_absolute = acc [7:0];    //cannot pass acc to strobe because it is a reg. Acc must be a reg inside this module.
                                          //acc_absolute is a wire, can be passed to strobe


  always @(*) 
    if (opcode == 5'b00000 || opcode == 5'b01000 || opcode == 5'b10000 || opcode == 5'b11001 || opcode == 5'b11101 || (opcode == 5'b11010 && instr [2:0] == 3'b010)) begin
   	  acc [7:0] <= write_data_acc [7:0];
   		read_data_acc [7:0] <= write_data_acc [7:0];
   		end
            
   	else begin
   		read_data_acc [7:0]  <= acc [7:0] ;    //if not writin to $acc, always read
   		end


  initial begin                             
    #0 
    acc [7:0] = 8'b00000000;         //initialize $acc at 0
    end


  //PRINT $ACC COMMAND
  always @ (print_acc)
    if (print_acc==1) begin 
      $strobe ("%d", acc_absolute);    //as a redundant precaution: strobing acc_absolute instead of read_data_acc 
      end

  //PART OF PRINT REGS COMMAND
  always @ (print_regs)
    if (print_regs==1) begin 
      $strobe ("$Acc= %d    $Acc=%2h", acc_absolute, acc_absolute);
      end

endmodule