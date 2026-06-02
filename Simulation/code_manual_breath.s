# Init things
init:
    # T_total defines the PWM frequency. 
    addi x10, x0, 1000     # x10 = T_total = 1000
    
    # Start at 50% intensity
    addi x11, x0, 500      # x11 = T_high = 500
    
    # State Variables
    add x12, x0, x0        # x12 = PWM counter = 0
    add x20, x0, x0        # x20 = previous_button_state = 0
    
    # Constants
    addi x25, x0, 100      # x25 = 10% step size (100)
    addi x26, x0, -1       # x26 = All LEDs ON mask (0xFFFFFFFF)
  
# Do something  
main:
    # Check if counter (x12) < T_high (x11)
    slt x13, x12, x11      
    beq x13, x0, turn_off  # If counter >= T_high, branch to turn_off

turn_on:
    add x30, x0, x26       # Write 0xFFFFFFFF to x30 (LEDs ON)
    jal x0, increment_pwm

turn_off:
    add x30, x0, x0        # Write 0 to x30 (LEDs OFF)

increment_pwm:
    addi x12, x12, 1       # counter++
    
    # Check if counter (x12) < T_total (x10)
    slt x13, x12, x10      
    beq x13, x0, end_pwm_cycle # If counter >= T_total, end the cycle
    jal x0, main      # Otherwise, keep looping the PWM

# END OF CYCLE: BUTTON READING & DEBOUNCING
# We only check the buttons at the end of a PWM cycle. 
# This acts as a natural software debounce because it limits the polling rate.
end_pwm_cycle:
    add x12, x0, x0        # Reset PWM counter to 0
    
    add x21, x0, x31       # Read current button states from x31
    xori x23, x20, -1      # Invert previous button state (NOT prev_state)
    and x22, x21, x23      # x22 (just_pressed) = curr_state AND (NOT prev_state)
    add x20, x0, x21       # Update previous state: prev_state = curr_state

# PROCESS BUTTON PRESSES
check_btn_0:
    # Button 0 (Bit 0): INCREASE INTENSITY
    andi x24, x22, 1       # Extract bit 0 from just_pressed mask
    beq x24, x0, check_btn_1 # If 0, skip to next button
    
    add x11, x11, x25      # T_high += 10%
    
    # Cap intensity at 100% (T_total)
    slt x13, x10, x11      # if T_total < T_high, x13 = 1
    beq x13, x0, check_btn_1 # If not over the limit, proceed
    add x11, x0, x10       # T_high = T_total (Clamp to 100%)

check_btn_1:
    # Button 1 (Bit 1): DECREASE INTENSITY
    andi x24, x22, 2       # Extract bit 1 from just_pressed mask
    beq x24, x0, finish_cycle # If 0, skip to end
    
    # Floor intensity at 0%
    # Using 'slt' to check if T_high went negative (less than 0)
    slt x13, x11, x25       
    beq x13, x0, safe_sub # If not below zero, proceed
    add x11, x0, x0        # T_high = 0 (Clamp to 0%)
	jal x0, finish_cycle
	
safe_sub:
    sub x11, x11, x25      # T_high -= 10%

finish_cycle:
    jal x0, main      # Start the next PWM cycle
	
# Life saver ! Keep it
life_saver:
  jal  x0 init