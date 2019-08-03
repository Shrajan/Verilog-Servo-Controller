////////////////////////////////////////////////////////////////////////////////
 /*
 FPGA Project Name     : N - Channel Servo Motor Controller
 Top level Entity Name : N_Channel_Servo_Controller_tb
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
`timescale 1 ns /100 ps
module N_Channel_Servo_Controller_tb;

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

/* Parameter List of the Servo_Motor_Controller_tb */
localparam CLOCK_FREQ 		  = 50000000             ; 		                    // Current Clock frequency (in Hz).
localparam RST_CYCLES 		  = 1		             ;        		            // Number of cycles of reset at beginning.
localparam REPEAT_DUTY_CYCLES = 2000000              ;							// Repeat values for different values of the input.
localparam WAIT_PERIOD        = 2		             ;							// Creating a repeat block to make the reset the load signal.
localparam NO_OF_CHANNEL      = 4					 ;							// The number of servos to be controlled corresponding to number of PWM signals.
localparam ADDRESS_WIDTH      = `clog2(NO_OF_CHANNEL);							// Determine the required width to of the servo selector.

/* Test Bench Generated Signals of the Servo_Motor_Controller_tb */
reg TB_CLOCK  									;								// Connects to the clock of the servo motor controller.
reg TB_RESET 									;								// Connects to the reset of the servo motor controller.
reg TB_LOAD_SIGNAL								;								// Connects to the load signal of the servo motor controller.
reg [7:0] TB_DUTY_CYCLE_CONTROL 				;								// Connects to the 8-bit duty cycle control of the servo motor controller.
reg [(ADDRESS_WIDTH-1):0] TB_SERVO_SELECTOR		;								// Connects to the N-bit servo selector of the servo motor controller.			

/* Device Under Test (DUT) Output Signals of the Servo_Motor_Controller_tb */
wire [(NO_OF_CHANNEL-1):0] TB_PWM_SIGNALS;										// Connects to the N-bit PWM signal of the servomotors.

/* Device Under Test (DUT) of the Servo_Motor_Controller_tb */
N_Channel_Servo_Controller      N_Channel_Servo_Controller_DUT (				// Setting the connections to their corresponding ports. 

   .CLOCK		        ( TB_CLOCK              ),
   .RESET		        ( TB_RESET              ),
   .LOAD_SIGNAL         ( TB_LOAD_SIGNAL        ),
   .DUTY_CYCLE_CONTROL  ( TB_DUTY_CYCLE_CONTROL ),
   .SERVO_SELECTOR  	( TB_SERVO_SELECTOR		),
   .PWM_SIGNALS         ( TB_PWM_SIGNALS        )
);

	/* Reset the entire control system so that the servo initializes to the default value. */
	initial begin
		TB_RESET = 1'b1;                                      					// Set the reset signal to HIGH.
		TB_LOAD_SIGNAL = 1'b1;													// Set the load signal to HIGH.
		repeat( RST_CYCLES ) @ ( posedge TB_CLOCK );               				// Wait for a couple of clocks.
		TB_RESET = 1'b0;                                      					// Set the reset signal to LOW.
		TB_LOAD_SIGNAL = 1'b0;													// Set the load signal to LOW.
	end

	/* Clock generator and simulation time limit. */
	initial begin
		TB_CLOCK = 1'b0; 														// Initialise the clock to zero.
	end

	real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;          // Calculating the time delay for each half of the clock cycle and storing it in a variable.
	integer half_cycles = 0;													// Variable to count the elapsed number of half cycles.

	always begin
		
		/* Duty Cycle Control = 0 and servo selector = 0*/ 
		repeat ( REPEAT_DUTY_CYCLES ) 						 					// Repeat the loop for some time.	
			begin 
			
				TB_DUTY_CYCLE_CONTROL = 8'd0;									// Assign a value of 0 for the duty cycle control.
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				TB_SERVO_SELECTOR = 2'd0;										// Select the first servo.
				TB_LOAD_SIGNAL = 1'b1;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
			end
		
		repeat ( WAIT_PERIOD ) 								 					// Repeat the loop for some time.
			begin 
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
				TB_LOAD_SIGNAL = 1'b0;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
			end
		
		////////////////////////////////////////////////////////////////////////
			
		/* Duty Cycle Control = 128 and servo selector = 1*/ 
		repeat ( REPEAT_DUTY_CYCLES ) 						 					// Repeat the loop for some time.	
			begin 
			
				TB_DUTY_CYCLE_CONTROL = 8'd128;									// Assign a value of 128 for the duty cycle control.
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				TB_SERVO_SELECTOR = 2'd1;										// Select the second servo.
				TB_LOAD_SIGNAL = 1'b1;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
			end
		
		repeat ( WAIT_PERIOD ) 								 					// Repeat the loop for some time.
			begin 
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
				TB_LOAD_SIGNAL = 1'b0;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
			end
		
		////////////////////////////////////////////////////////////////////////
		
		/* Duty Cycle Control = 255 and servo selector = 2*/ 
		repeat ( REPEAT_DUTY_CYCLES ) 						 					// Repeat the loop for some time.	
			begin 
			
				TB_DUTY_CYCLE_CONTROL = 8'd255;									// Assign a value of 255 for the duty cycle control.
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				TB_SERVO_SELECTOR = 2'd2;										// Select the third servo.
				TB_LOAD_SIGNAL = 1'b1;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
			end
		
		repeat ( WAIT_PERIOD ) 								 					// Repeat the loop for some time.
			begin 
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
				TB_LOAD_SIGNAL = 1'b0;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
			end
		
		////////////////////////////////////////////////////////////////////////
		
		/* Duty Cycle Control = 192 and servo selector = 3*/ 
		repeat ( REPEAT_DUTY_CYCLES ) 						 					// Repeat the loop for some time.	
			begin 
			
				TB_DUTY_CYCLE_CONTROL = 8'd192;									// Assign a value of 192 for the duty cycle control.
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				TB_SERVO_SELECTOR = 2'd3;										// Select the fourth servo.
				TB_LOAD_SIGNAL = 1'b1;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
			end
		
		repeat ( WAIT_PERIOD ) 								 					// Repeat the loop for some time.
			begin 
				
				/* Generating individual half cycles of clock */
				#(HALF_CLOCK_PERIOD);          									// Delay for half a clock period.
				TB_CLOCK = ~ TB_CLOCK;                							// Toggle the clock signal.
				half_cycles = half_cycles + 1; 									// Increment the count of number of half cycles.
				
				TB_LOAD_SIGNAL = 1'b0;											// Set the load signal to HIGH so that the output latches on to the required duty cycle.
			end
		
		$stop;                    												// Break the simulation

		
	end

endmodule