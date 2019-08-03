////////////////////////////////////////////////////////////////////////////////
 /*
 FPGA Project Name     : N - Channel Servo Motor Controller
 Top level Entity Name : Frequency_Divider
 Target Device		   : Cyclone V
 
 Code Author           : Shrajan Bhandary
 Date Created          : 08/03/2019 
 Location 			   : University of Leeds
 Module 			   : ELEC5566M FPGA Design for System-on-chip
 
 -------------------------------------------------------------------------------
 
 Description of the Verilog Module: 
	The module is used to reduce the incoming clock rate to a fixed value. 
	The fixed value is 128 kHz and the incoming clock rate can vary from 128 kHz
	to 100 MHz. 
 
 */
//////////////////////////////////////////////////////////////////////////////// 

module Frequency_Divider #(														// Start of the module.

    /* Parameter List of the Frequency_Divider */
    parameter 	INCOMING_CLOCK_FREQUENCY  = 50000000,							// The minimum operable frequency is 128 kHz and the maximum operable frequency is 100 MHz.
	parameter 	FIXED_CLOCK_FREQUENCY     = 128000,								// All the servo default parameters are calculated at this frequency.
	parameter 	TOGGLE = (INCOMING_CLOCK_FREQUENCY / FIXED_CLOCK_FREQUENCY)/2,  // The toggle value is used to change the state of the output. The maximum value is 781.
	parameter	MAXIMUM_WIDTH             = 10    ,								// 10 bits to encompass all the possible values of toggle.
	parameter   INCREMENT				  = 1                                   // The value by which the clock counter should increase.
	
)(
	/* Port List of the Servo_Motor_Controller */
    input     	FD_CLOCK_IN,													// The incoming clock is connected to this port.	
    input       FD_RESET,														// The reset pin is connected to this port.
    output reg 	FD_CLOCK_OUT													// This provides the fixed clock rate depending upon the divider value.
);
	wire [(MAXIMUM_WIDTH-1):0] CURRENT_COUNTER ; 								// This maximum value of the counter will be equal to the toggle which needs 10 bits.
	
	localparam LOW  = 0;														// 1 bit Local parameter with value 0
	localparam HIGH = 1; 														// 1 bit Local parameter with value 1

	/* Instantiating the N Bit counter to count values up to Toggle */
	N_Bit_Counter # 		  (
		. COUNTER_VALUE_WIDTH ( MAXIMUM_WIDTH   ),
		. COUNTER_MAX_VALUE	  ( TOGGLE		    ),
		. COUNTER_INCREMENT	  ( INCREMENT	    )
	
	) FD_Toggler 			  (
		. COUNTER_CLOCK		  ( FD_CLOCK_IN	    ),
		. COUNTER_RESET		  ( FD_RESET	    ),
		. COUNTER_ENABLE      ( HIGH			),
		. COUNTER_VALUE	      (	CURRENT_COUNTER )
	);
	
	always @ ( posedge FD_CLOCK_IN or posedge FD_RESET )						// Always statement such that the counter value changes when either
		begin																	// reset or clock change from LOW to HIGH.
				
				if ( FD_RESET ) 												// Check whether reset is HIGH.												
					begin
						FD_CLOCK_OUT <= LOW;									// Reset the initialize the clock.
					end 
		
				else if ( CURRENT_COUNTER == TOGGLE )							// Check if the toggle value has been reached.
					begin 
						FD_CLOCK_OUT <= ~ FD_CLOCK_OUT;							// Switch (LOW to HIGH or HIGH to LOW ) the output clock when the current value has reached the toggle value.
					end
		end
	
endmodule
