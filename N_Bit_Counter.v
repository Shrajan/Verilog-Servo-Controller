////////////////////////////////////////////////////////////////////////////////
 /*
 FPGA Project Name   : N - Channel Servo Motor Controller
 Verilog Module Name : N_Bit_Counter
 
 Code Author         : Shrajan Bhandary
 Date Created        : 26/02/2019 
 Location 			 : University of Leeds
 Module 			 : ELEC5566M FPGA Design for System-on-chip
 
 -------------------------------------------------------------------------------
 
 Description of the Verilog Module: 
	The module is used to count values ranging from 0 to required maximum value. 
	Once the maximum value is reached the counter is reset to 0. The counter 
	increments at every positive edge of clock signal and can be reset at every 
	positive edge of the reset signal i.e., when the reset button is pressed. 
	For this project the maximum value corresponds to the clock period (20 ms) 
	of the PWM Signal of the Servo Motor.
 
 */
////////////////////////////////////////////////////////////////////////////////

module N_Bit_Counter #(															// Start of the module.
    
	/* Parameter List of the N_Bit_Counter */
	parameter                				COUNTER_VALUE_WIDTH = 12,			// The default width is 12 bits.
    parameter         COUNTER_MAX_VALUE = (2**COUNTER_VALUE_WIDTH)-1,			// The maximum value that corresponds to (2^width - 1).
    parameter               				COUNTER_INCREMENT   = 1				// The counter should increment by 1 every clock cycle.
	
)(
    /* Port List of the N_Bit_Counter */
    input                    				COUNTER_CLOCK    ,					// Counter increments according to the clock. 
    input                    				COUNTER_RESET    ,  				// Counter resets to 0 when reset becomes HIGH.
    input                    				COUNTER_ENABLE   ,  				// Counter increments only if enable is HIGH.
    output reg [(COUNTER_VALUE_WIDTH-1):0]  COUNTER_VALUE = 0 					// The final count value of the counter.
);
	/* Local Parameter List of the N_Bit_Counter */
	localparam ZERO = {(COUNTER_VALUE_WIDTH){1'b0}}; 							// Local parameter with value 0 having default width of 12 bits.

	always @ ( posedge COUNTER_CLOCK or posedge COUNTER_RESET )					// Always statement such that the counter value changes when either
		begin																	// reset or clock change from LOW to HIGH.
		
			if ( COUNTER_RESET ) 												// Check whether reset is HIGH.
				begin
					COUNTER_VALUE <= ZERO;										// Set counter value to 0 if reset is HIGH.
				end 
			
			else if ( COUNTER_ENABLE ) 											// Check if enable is HIGH
				begin
			   
					if ( COUNTER_VALUE >= COUNTER_MAX_VALUE ) 					// Check if counter value has surpassed maximum value.
						begin
							COUNTER_VALUE <= ZERO;								// Set counter value to 0 if counter value has surpassed maximum value.
						end 
					
					else 
						begin
							COUNTER_VALUE <= COUNTER_VALUE + COUNTER_INCREMENT;	// If none of the above conditions satisfy, then increment the counter value.
						end
				end
		end
endmodule																		// End of the module.
