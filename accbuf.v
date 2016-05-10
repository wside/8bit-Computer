module accbuf (input [7:0] write_data_accbuf, output [7:0] read_data_accbuf, input CLK);   //CLK controls the buffer

	wire signed [7:0] write_data_accbuf;                                       
 	reg signed [7:0] read_data_accbuf; 
	
	
	reg signed [7:0] accbuf;      //ACCUMULATOR BUFFER declared here


	always @ (posedge CLK)       //read in values from $acc at positive edge
		
		if(CLK) begin
 			accbuf  [7:0] <= write_data_accbuf [7:0];
 			read_data_accbuf [7:0] <= write_data_accbuf [7:0];     //so write_data immidieatly goes to read_data
 			end
 		else begin
 			read_data_accbuf [7:0] <= accbuf  [7:0];        //if not writing to buffer, always read from it
 			end

endmodule 




