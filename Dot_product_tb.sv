module Dot_product_tb; 
	reg clk,reset,data_RW;
	reg [31:0]in;
	wire [3:0]sel;
	wire [8:0][31:0] out;
	wire [31:0] out_product;
	
		Dot_product dot_(.in(in),.clk(clk),.reset(reset),.out(out_product),.sel(sel));
		Register_32bits memory(.D(out_product),.select(sel),.clk(clk),.out(out));
		initial 
		begin
			//get matrix slots sequence   
			data_RW=1; //enable
			reset=1; 	// counter=0
			clk=0;
			#1
			reset=0;
				clk=1;
				in=8+65536*17;
			#1
			clk=0;//1
			#1
				clk=1;
				in=7+65536*16;
			#1
			clk=0;//2
			#1
				clk=1;
				in=6+65536*15;
			#1
			clk=0;//3
			#1
				clk=1;
				in=5+65536*14;
			#1
			clk=0;//4
			#1
				clk=1;
				in=4+65536*13;
			#1
			clk=0;//5
			#1
				clk=1;
				in=3+65536*12;
			#1
			clk=0;//6
			#1
				clk=1;
				in=2+65536*11;
			#1
			clk=0;//7
			#1
				clk=1;
				in=1+65536*10;
			#1
			clk=0;//8
			#1
				clk=1;
				in=0+65536*9;//a(left matrix)+b(right matrix)
			#1
				data_RW=0;
				reset=1;
				clk=0;
			#1
			clk=1;
			reset=0;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
			#1
				clk=0;
			#1
			clk=1;
		end
								
endmodule 