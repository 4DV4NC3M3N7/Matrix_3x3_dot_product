module Dot_product_tb; 
	reg clk,reset,data_RW;
	reg [31:0]in;
	wire [3:0]sel;
	wire [8:0][31:0] out;
	wire [31:0] out_product;
	
	/*
		assign sel_wire[0] = sel[0]&data_RW;
		assign sel_wire[1] = sel[1]&data_RW;
		assign sel_wire[2] = sel[2]&data_RW;
		assign sel_wire[3] = sel[3]&data_RW;
		//==================================
		assign d_wire[3]=d[3]&~data_RW;
		assign d_wire[2]=d[2]&~data_RW;
		assign d_wire[1]=d[1]&~data_RW;
		assign d_wire[0]=d[0]&~data_RW;
		FSM fsm(.clk(clk),.reset(reset),.d(d),.sel(sel));
		Dot_product dot(
									.in(in),
									.sel(d_wire),
									.mem_sel(sel_wire),
									.data_RW(data_RW),
									.clk(clk),
									.out(out)
						      );
						*/
		Dot_product dot_(.in(in),.clk(clk),.reset(reset),.data_RW(data_RW),.out(out_product),.sel_wire(sel));
		Register_32bits memory(.D(out),.Data_RW(data_RW),.select(sel),.clk(clk),.out(out));
		initial 
		begin
			//get matrix slots sequence
			data_RW=1;
			reset=1;
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
		end
								
endmodule 