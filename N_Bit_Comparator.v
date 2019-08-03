////////////////////////////////////////////////////////////////////////////////
 /*
 FPGA Project Name   : N - Channel Servo Motor Controller
 Verilog Module Name : N_Bit_Comparator
 
 Code Author         : Shrajan Bhandary
 Date Created        : 26/02/2019 
 Location 			 : University of Leeds
 Module 			 : ELEC5566M FPGA Design for System-on-chip
 
 -------------------------------------------------------------------------------
 
 Description of the Verilog Module: 
	The module is used compare the value of two numbers. The output of the 
	module is HIGH when the first number is greater than or equal to the second 
	number. The output of the module is LOW when the first number is smaller 
	than the second number. The time period for which the output of the 
	comparator is HIGH determines the ON_PERIOD of the PWM Signal of the Servo
	Motor.
 
 */
////////////////////////////////////////////////////////////////////////////////

module N_Bit_Comparator  #(														// Start of the module.

    /* Parameter List of the N_Bit_Comparator */
    parameter  						NUMBER_WIDTH = 12							// The default width is 12 bits to match value from the counter.
	
)( 
	/* Port List of the N_Bit_Comparator */
    input  	  [(NUMBER_WIDTH-1):0]  FIRST_NUMBER      ,							// The first number of the comparator.
    input     [(NUMBER_WIDTH-1):0]  SECOND_NUMBER     , 						// The second number of the comparator.
    output reg					    FN_GREATER_THAN_SN 							// The output of the comparator.
);
	always @ ( FIRST_NUMBER , SECOND_NUMBER )						
		begin
			
			if ( FIRST_NUMBER >= SECOND_NUMBER )								// LOW if second number is greater than first number, else HIGH.
				begin 
					FN_GREATER_THAN_SN <= 1'b1;
				end
				
			else
				begin
					FN_GREATER_THAN_SN <= 1'b0;
				end
		end
endmodule																		// End of the module.
