# INITIALIZATION
    # Set the speed of the chaser
    addi x10, x0, 2000     # x10: chaser_delay
    addi x10, x10, 2000     # x10: chaser_delay
    add  x11, x0, x0       # x11: delay_counter = 0
    
    # Initialize state
    addi x12, x0, 1        # x12: led_state = 1 (Starts at LED 0)
    addi x13, x0, 1        # x13: running_flag = 1 (Starts running)
    add  x20, x0, x0       # x20: prev_btn_state = 0

# MAIN LOOP & LED OUTPUT
main_loop:
    add x30, x0, x12       # Write the current led_state to x30

# 2. DELAY TIMER
timer_logic:
    addi x11, x11, 1       # delay_counter++
    slt  x28, x11, x10     # if delay_counter < chaser_delay
    beq  x28, x0, move_led # Timer finished! Time to move the LED.
    jal  x0, check_btns    # Timer not finished, just read buttons.

# CHASER SHIFTING LOGIC
move_led:
    add x11, x0, x0        # Reset delay_counter to 0
    
    # Check if the chaser is currently paused
    beq x13, x0, check_btns
    
    # Shift the lit LED one position to the left
    slli x12, x12, 1       
    
    # If the bit shifts past the 31st LED, the register becomes 0.
    # We can detect this and reset the chaser to the 0th LED.
    beq  x12, x0, reset_led
    jal  x0, check_btns

reset_led:
    addi x12, x0, 1        # Reset led_state back to 1

# BUTTON DEBOUNCING & CONTROL
check_btns:
    add  x21, x0, x31      # Read current buttons from x31
    xori x23, x20, -1      # Invert prev_btn_state
    and  x22, x21, x23     # just_pressed = current AND (NOT prev)
    add  x20, x0, x21      # Update prev_btn_state

btn_0:
    # STOP CHASER
    andi x24, x22, 1
    beq  x24, x0, btn_1
    add  x13, x0, x0       # running_flag = 0

btn_1:
    # RESTART CHASER FROM 0
    andi x24, x22, 2
    beq  x24, x0, end_loop
    addi x13, x0, 1        # running_flag = 1
    addi x12, x0, 1        # reset led_state = 1

end_loop:
    jal  x0, main_loop     # Go back to start