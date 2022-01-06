module Register_(Q,D,Data_RW,clk);//flip_flop_cell,add "enable" if need a tristate lock at the output. 
		input D;
		input clk,Data_RW;
		output reg Q;
		generate 
		always @ ( posedge clk )
			begin
			if(Data_RW)
					Q <= D;
			//else 
					//Q <= 0;
				end
		endgenerate
endmodule 
//========================================================
module Register(D,Data_RW,data_out,select,clk);//flip_flop_cell,add "enable" if need a tristate lock at the output. //register file 16bits
		input [15:0]D;
		input [3:0]select;
		input Data_RW,clk;//Data_RW=0 is Read/1 is Write .

		output[8:0][15:0]data_out;
		wire [8:0][15:0]Q;
		wire [8:0]decode,clock;
		wire [15:0][8:0]mux_;
		decoder_4bits deco(.sel(select),.out_put(decode));
	
		genvar i,j;	
		generate 
		for(j=0;j<9;j++)
		begin : wiring_address
			assign clock[j]=clk&decode[j];
			for(i=0;i<16;i++)
			begin : wiring_width
					Register_ cell_(Q[j][i],D[i],decode[j]&Data_RW,clk);
			end 
		end
		assign data_out=Q;
		endgenerate
endmodule 
///*
module Register_32bits(D,Data_RW,select,clk,out);//flip_flop_cell,add "enable" if need a tristate lock at the output. //register file 16bits
		input [31:0]D;
		input [3:0]select;
		input Data_RW,clk;//Data_RW=0 is Read/1 is Write .
		wire [8:0][31:0]Q;
		wire [8:0]decode;
		output[8:0][31:0] out;
		decoder_4bits deco(.sel(select),.out_put(decode));
	
		genvar i,j;	
		generate 
		for(j=0;j<9;j++)
		begin : wiring_address
			
		for(i=0;i<32;i++)
			begin : wiring_width
					Register_ cell_(Q[j][i],D[i],decode[j]&~Data_RW,clk);
			end 
			assign out[j][31:0]=Q[j][31:0];
		end
		
		endgenerate
endmodule 
//*/
//=========================================================
module decoder_4bits(sel,out_put);
		input [3:0]sel;
		output [8:0]out_put;
		
					assign out_put[0]=~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[1]=~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[2]=~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[3]=~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[4]=~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[5]=~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[6]=~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[7]=~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[8]=sel[3]&~sel[2]&~sel[1]&~sel[0];
endmodule
//=========================================================
module MUX_9_to_1bits(in_put,sel,final_out);
		input[3:0]sel;
		input[8:0] in_put;
		wire [8:0]out_put;
		output final_out;
					assign out_put[0]=in_put[0]&~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[1]=in_put[1]&~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[2]=in_put[2]&~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[3]=in_put[3]&~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[4]=in_put[4]&~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[5]=in_put[5]&~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[6]=in_put[6]&~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[7]=in_put[7]&~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[8]=in_put[8]&sel[3]&~sel[2]&~sel[1]&~sel[0];
			assign final_out = out_put[0]|out_put[1]|out_put[2]|out_put[3]|out_put[4]|out_put[5]|out_put[6]|out_put[7]|out_put[8];	
		endmodule
//genvar i;
		//generate
			//for(i=0;i<18;i++)
			//begin : wiring
					
			//end
		//endgenerate 