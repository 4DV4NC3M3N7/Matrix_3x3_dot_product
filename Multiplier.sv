module Multiplier_unit	(
					input a,Sin,Cin,
					inout b,
					output Sout,Cout
					);
					
	full_adder block0(.a(Sin),.b(a&b),.Cin(Cin),.Sout(Sout),.Cout(Cout));
 
endmodule 

module full_adder(
						input a,b,Cin,
						output Sout,Cout
					  );
		assign Sout = ((a^b)^Cin);
		assign Cout = (a&b)|((a^b)&Cin);
					  
endmodule 

module Multiplier(

	input			[15:0]	A,
	input			[15:0]	B,
	output	   [31:0]   OUT
);
wire [16:-1][16:-1] Sout,Cout;
wire [15:0]cout;
//=======================================================
//  REG/WIRE declarations
//=======================================================
genvar i,j; 
generate 
	
		for(i=0;i<16;i++)
		begin : row
			Multiplier_unit bits(.a(A[i]), .b(B[0]), .Sin(Sout[i][-1]), .Cin(0)            , .Sout(Sout[i][0]), .Cout(Cout[i][0]));
			assign Sout[i][-1]=0;
		end
	for(j=1;j<16;j++)
	begin : columns
		for(i=0;i<15;i++)
		begin : rows
			Multiplier_unit bits(.a(A[i]), .b(B[j]), .Sin(Sout[i+1][j-1]), .Cin(Cout[i][j-1])  , .Sout(Sout[i][j]), .Cout(Cout[i][j]));
		end
	end
		for(j=1;j<16;j++)
		begin : column
			Multiplier_unit bits(.a(A[15]), .b(B[j]), .Sin(0), .Cin(Cout[15][j-1]) , .Sout(Sout[15][j]), .Cout(Cout[15][j]));
			assign Sout[16][j]=0;
		end		 
		for(i=0;i<16;i++) 
		begin: as
			assign OUT[i]=Sout[0][i];
			assign OUT[i+16]=Sout[i][15]; 
		end
endgenerate 
 //=======================================================
//  Structural coding
//========================================================

endmodule 