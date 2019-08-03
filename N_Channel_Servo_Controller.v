////////////////////////////////////////////////////////////////////////////////
 /*
 FPGA Project Name     : N - Channel Servo Motor Controller
 Top level Entity Name : N_Channel_Servo_Controller
 Target Device		   : Cyclone V
 
 Code Author           : Shrajan Bhandary
 Date Created          : 08/03/2019 
 Location 			   : University of Leeds
 Module 			   : ELEC5566M FPGA Design for System-on-chip
 
 -------------------------------------------------------------------------------
 
 Description of the Verilog Module: 
	The module is used to instantiate a parametrized number of servo controllers 
	to allow the IP core to have N independent channels. This module has a clock 
	input, an N-bit PWM output, a single 8-bit input to set the duty cycle, a 
	1-bit load signal to latch the duty cycle value, and an address input to 
	control which servo is being updated. 
 
 */
//////////////////////////////////////////////////////////////////////////////// 

/* ceil(log2(N)) Preprocessor Macro */
`define clog2(x) ( \
	((x) <= 2) ? 1 : \
	((x) <= 4) ? 2 : \
	((x) <= 8) ? 3 : \
	((x) <= 16) ? 4 : \
	((x) <= 32) ? 5 : \
	((x) <= 64) ? 6 : \
	((x) <= 128) ? 7 : \
	((x) <= 256) ? 8 : \
	((x) <= 512) ? 9 : \
	((x) <= 1024) ? 10 : \
	((x) <= 2048) ? 11 : \
	((x) <= 4096) ? 12 : 16)

module N_Channel_Servo_Controller #(											// Start of the module.

    /* Parameter List of the N_Channel_Servo_Controller */
	parameter 	NO_OF_CHANNEL	 = 4					,						// The number of servos to be controlled corresponding to number of PWM signals.
	parameter 	ADDRESS_WIDTH 	 = `clog2(NO_OF_CHANNEL),						// Determine the required width to of the servo selector.
    parameter 	CLOCK_FREQUENCY  = 50000000 			,						// The minimum operable frequency is 128 kHz and the maximum operable frequency is 100 MHz. ( In Hz).
	parameter 	DUTY_CYCLE_WIDTH = 8  					,						// The number of bits for the duty cycle control.
	parameter	INVERTED_INPUT   = 1        									// Parameter to select between active LOW ( Invert = 1 ) inputs and active HIGH ( Invert = 0 )inputs. 
																				// Inverted input should be 0 and 1 for test bench verification and hardware verification respectively.
)(
	/* Port List of the N_Channel_Servo_Controller*/
    input     						CLOCK             ,							// The incoming clock is connected to this port.	
    input       					RESET             ,							// The reset pin is connected to this port.
    input 							LOAD_SIGNAL       ,							// Latch the duty cycle of the PWM signal.
	input  [(DUTY_CYCLE_WIDTH-1):0]	DUTY_CYCLE_CONTROL,							// Controls the duty cycle of the PWM signal, thus controlling the angle.
	input  [(ADDRESS_WIDTH-1):0]	SERVO_SELECTOR	  ,							// Determines the servo that has to be actuated.
	output [(NO_OF_CHANNEL-1):0]	PWM_SIGNALS									// The output of the module that is the input to the Servo motor.

);
	wire CLOCK_CONNECTOR;														// Net to connect output of the frequency divider to the servo motor controller.
	reg INVERT_RESET;															// Inverts the input reset signal for LOW active low inputs.
	reg INVERT_LOAD_SIGNAL;														// Inverts the input load signal for LOW active low inputs.
	localparam HIGH_VALUE = 1; 													// Local parameter with value 1.
	
	reg [(NO_OF_CHANNEL-1):0]INDIVIDUAL_LOAD ;									// Each channel has its individual load register.
	
	/* To check whether the inputs are active LOW or not and then take necessary actions */
	always @ ( RESET , LOAD_SIGNAL ) begin										// Always statement that changes with respect to reset and load signals.
		
		if ( INVERTED_INPUT )													// Check if the inputs are active LOW or active HIGH.
			begin																// If yes, invert the inputs.
				INVERT_RESET <= ~ RESET;									
				INVERT_LOAD_SIGNAL <= ~ LOAD_SIGNAL;
			end
		
		else 
			begin																// If no, assign the same inputs.
				INVERT_RESET <= RESET;
				INVERT_LOAD_SIGNAL <= LOAD_SIGNAL;
			end
	end

	/* Instantiating the frequency divider to convert incoming clock frequency to fixed frequency. */
	Frequency_Divider #      (													
		. INCOMING_CLOCK_FREQUENCY	( CLOCK_FREQUENCY )
	
	) Clock_Enable_Generator (
		. FD_CLOCK_IN				( CLOCK			  ),
		. FD_RESET					( INVERT_RESET	  ),
		. FD_CLOCK_OUT				( CLOCK_CONNECTOR )
	
	);
	
	genvar COUNT;																// Creating a general variable to implement a for loop.
	
	generate
	for ( COUNT = 0 ; COUNT < NO_OF_CHANNEL ; COUNT = (COUNT + 1) ) 			// Creating a for loop to instantiate N number of servomotors.
		begin : Servo_Motor_Driver_Block_loop
			
			localparam NUMBER = COUNT ;											// A local parameter to hold the number of possible servo combinations.
			
			/* To check the value of the load signal and then take necessary actions. */
			always @ ( INVERT_LOAD_SIGNAL  )									 
				begin
				
					if ( INVERT_LOAD_SIGNAL )									// Check whether the load signal button has been pressed.
						begin
						
							if ( SERVO_SELECTOR == NUMBER )						// Check if the input selector is same as that of the current servomotor ID.
								begin 
									INDIVIDUAL_LOAD[COUNT] <= 1'b1;				// Set the load of that particular servomotor to HIGH. (This signal should not remain always HIGH).
								end
							else 
								begin 
									INDIVIDUAL_LOAD[COUNT] <= 1'b0;				// If the input selector does not match to the current servomotor ID, then set the load of the 
								end 											// that particular servomotor to HIGH.
						end
					
					else 
						begin 
							INDIVIDUAL_LOAD[COUNT] <= 1'b0;						// Once the load signal button is released set all the load signals to LOW.
						end
				end
				
			Servo_Motor_Controller Servo_Motor_Driver_Block (					// Instantiating N number of servomotors with separate PWM signal and load signal.
			
				. CLOCK_SIGNAL		    ( CLOCK_CONNECTOR	 	 ),
				. CLOCK_ENABLE			( HIGH_VALUE	     	 ),
				. SERVO_RESET 			( INVERT_RESET	 	 	 ),
				. LOAD_SIGNAL			( INDIVIDUAL_LOAD[COUNT] ),
				. DUTY_CYCLE_CONTROL	( DUTY_CYCLE_CONTROL 	 ),
				. PWM_SIGNAL			( PWM_SIGNALS [COUNT]	 )
			);
		end
	endgenerate
	
endmodule																		// End of the module.	
