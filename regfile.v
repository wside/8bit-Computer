module regfile

  (input RegWrite,
  input [2:0] write_reg,        //control line
  input [7:0] write_data,
  input [2:0] read_reg1,
  output [7:0] read_data1,
  input [2:0] read_reg2,
  output [7:0] read_data2,
  input [2:0] read_reg3,
  output [7:0] read_data3, 
  input print_regs);  //syscall

  reg signed [7:0] read_data1;
  reg signed [7:0] read_data2;
  reg [7:0] read_data3;           //not signed since only used will be used as $d reg in beq: Holds bottom 8 bits of 10 bit offset from PC.
  
  wire print_regs;

  reg [7:0] test;
  
  wire [7:0] sp_unsigned ;     //$sp is an unsigned address, will print out as unsigned dec
  wire [7:0] gp_unsigned ;     //$gp is an unsigned address, will print out as unsigned dec


  reg signed [7:0]   regfile [0:7];       //REGISTER FILE declared here

   
  assign  sp_unsigned [7:0] = regfile [3'b010];
  assign  gp_unsigned [7:0] = regfile [3'b001];


  //initialize registers
  initial begin                             
    #0   
    regfile [3'b000] = 8'b00000000;       
    regfile [3'b001] = 8'b00000000;
    regfile [3'b010] = 8'b11111111;         //initialize $sp at 0xFF
    regfile [3'b011] = 8'b00000000;            
    regfile [3'b100] = 8'b00000000;
    regfile [3'b101] = 8'b00000000;
    regfile [3'b110] = 8'b00000000;
    regfile [3'b111] = 8'b00000000;
    end
  

  //ALWAYS READ if not write
  always @ (*) begin 
    read_data1 <= regfile[read_reg1];     //non blocking assignments "<=" used so read all three at same time
    read_data2 <= regfile[read_reg2];
    read_data3 <= regfile[read_reg3];
      end


  //WRITE REG
  always @(*) 
      if (RegWrite ==1 && write_reg != 3'b000) begin  //cannot write over the $0 register
         regfile[write_reg] <= write_data;
         end

  //PRINT REGS                    //$strobe prints the values at the end of the current timestep (strobed monitoring)
  always @ (print_regs)
    if (print_regs==1) begin 
      $strobe ("---------------------- \n$gp= %d      $gp= %2h\n$sp= %d      $sp= %2h\n$r0= %d      $r0= %2h\n$r1= %d      $r1= %2h\n$r2= %d      $r2= %2h\n$r3= %d      $r3= %2h\n$ra8= %d     $ra8= %2h\n", gp_unsigned, regfile[3'b001], sp_unsigned, regfile[3'b010],regfile[3'b100], regfile[3'b100],regfile[3'b101], regfile[3'b101],regfile[3'b110], regfile[3'b110],regfile[3'b111], regfile[3'b111],regfile[3'b011], regfile[3'b011]);
      end

endmodule