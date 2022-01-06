//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

// This adder has P,G,cout are outputs
	module full_adder_1_bit(a,b,sum_dif,p,g,cin,add_sub);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input a,b,cin,add_sub;
				output sum_dif,p,g;
				wire B;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				assign B = b ^ add_sub ;
				assign g = a & B ;
				assign p = a ^ B ;
				assign sum_dif =  a ^ B ^ cin ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

module carry_block_4bits(cin,p,g,carry_in,cout,P);		//carry_block_4bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				output		[3:0] cin ;
				input 		 carry_in ;
				input  [3:0] p , g ;
				output 		 cout, P ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				assign cin[0] = carry_in ;   						//the Cin entry
				
				assign cin[1] = ( cin[0] & p[0] ) | g[0] ; 	// going in next FA 1bits block
				
				assign cin[2] = ( cin[1] & p[1] ) | g[1] ;  	// going in next FA 1bits block
				
				assign cin[3] = ( cin[2] & p[2] ) | g[2] ;  	// going in next FA 1bits block
				
				assign cout   = ( cin[3] & p[3] ) | g[3] ;  	// cout is also 'G'
				
				assign P      = p[0] & p[1] & p[2] & p[3] ; 	//   'P'
//--------------------------------------------------------------------------------------------------------------------------------------------------						
				
				
	endmodule
//==================================================================================================================================================
//==================================================================================================================================================
//==================================================================================================================================================

		module FA_4bits(a,b,sum_dif,carry_in,cout,P,add_sub);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input  [3:0] a , b ;
				wire   [3:0] cin , p , g ;
				input        carry_in , add_sub;
				output [3:0] sum_dif ;
				output       cout , P ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
			//discrete block of 1 bit full adder
							full_adder_1_bit FA_0 (a[0],b[0],sum_dif[0],p[0],g[0],cin[0],add_sub);
							full_adder_1_bit FA_1 (a[1],b[1],sum_dif[1],p[1],g[1],cin[1],add_sub);
							full_adder_1_bit FA_2 (a[2],b[2],sum_dif[2],p[2],g[2],cin[2],add_sub);
							full_adder_1_bit FA_3 (a[3],b[3],sum_dif[3],p[3],g[3],cin[3],add_sub);

			//carry block 4bits
			carry_block_4bits CLA_4bits_0(cin[3:0],p[3:0],g[3:0],carry_in,cout,P);
//--------------------------------------------------------------------------------------------------------------------------------------------------				
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================	
	
		module Adder(a,b,sum_dif,carry_in,C,V,add_sub);	//FA_32bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input  [31:0] a , b ;  
				wire   [7:0] cin , p ,g ;		// for smaller 4bits modules
				wire   [1:0] Cin;			// for final 32bits joint
				input  	carry_in , add_sub;
				output [31:0] sum_dif ;
				wire [1:0]  P, G;
				output C,V;// C = Carry out; V = oVerflow.
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	// assembly of multiple 4-bits segments to one single 32-bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				FA_4bits block0(a[3:0],b[3:0],sum_dif[3:0],cin[0],g[0],p[0],add_sub);
				FA_4bits block1(a[7:4],b[7:4],sum_dif[7:4],cin[1],g[1],p[1],add_sub);
				FA_4bits block2(a[11:8],b[11:8],sum_dif[11:8],cin[2],g[2],p[2],add_sub);
				FA_4bits block3(a[15:12],b[15:12],sum_dif[15:12],cin[3],g[3],p[3],add_sub);
				
				carry_block_4bits CLA_4bits_1(cin[3:0],p[3:0],g[3:0],Cin[0],G[0],P[0]);// cout = g[3]; 'Cin[0]' entry for carry in 
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				FA_4bits block4(a[19:16],b[19:16],sum_dif[19:16],cin[4],g[4],p[4],add_sub);
				FA_4bits block5(a[23:20],b[23:20],sum_dif[23:20],cin[5],g[5],p[5],add_sub);
				FA_4bits block6(a[27:24],b[27:24],sum_dif[27:24],cin[6],g[6],p[6],add_sub);
				FA_4bits block7(a[31:28],b[31:28],sum_dif[31:28],cin[7],g[7],p[7],add_sub);
				
				carry_block_4bits CLA_4bits_2(cin[7:4],p[7:4],g[7:4],Cin[1],G[1],P[1]);// cout = g[3];
				
				// 2 bits carry block top of the add/sub module.
				assign  Cin[0]  = carry_in ;
				assign  Cin[1]  = ( Cin[0] & P[0] ) | G[0] ; 
				assign  C 	 	 = ( Cin[1] & P[1] ) | G[1] ;
				//assign  P_ 		 = P[1] & P[0] ;
				assign V = C^g[6]; // overflow detection in signed integer when addition of two positive numbers gives a negative result 
			//	assign V = (~C)&g[6]; // overflow detection in signed integer when addition of two positive numbers gives a negative result or in reverse
//--------------------------------------------------------------------------------------------------------------------------------------------------					
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================