# INITIALIZATION
    addi x10, x0, 1000     # x10: T_total (PWM Frequency)
    add  x11, x0, x0       # x11: T_high (Starts at 0 / LEDs OFF)
    add  x12, x0, x0       # x12: pwm_counter = 0
    
    addi x13, x0, 1000     # x13: max_intensity (Starts at 100%)
    addi x14, x0, 20       # x14: breath_delay (Lower = faster breathing)
    add  x15, x0, x0       # x15: breath_counter = 0
    addi x16, x0, 1        # x16: breath_dir (1 = getting brighter)
    addi x17, x0, 5        # x17: breath_step
    
    add  x20, x0, x0       # x20: prev_button_state = 0
    
    addi x25, x0, 5        # x25: speed_step (For Buttons 0 & 1)
    addi x26, x0, 100      # x26: intensity_step (For Buttons 2 & 3)
    addi x27, x0, -1       # x27: Mask for all LEDs ON (0xFFFFFFFF)

# MAIN PWM LOOP
main_loop:
    slt  x28, x12, x11     # if pwm_counter < T_high, x28 = 1
    beq  x28, x0, turn_off # if not less (>=), turn off

turn_on:
    add  x30, x0, x27      # Write to x30 to turn LEDs ON[span_4](end_span)
    jal  x0, inc_pwm

turn_off:
    add  x30, x0, x0       # Write 0 to x30 to turn LEDs OFF[span_5](end_span)

inc_pwm:
    addi x12, x12, 1       # pwm_counter++
    slt  x28, x12, x10     # if pwm_counter < T_total
    beq  x28, x0, end_pwm  # Cycle finished, handle breathing
    jal  x0, main_loop     # Else, keep doing PWM

# BREATHING LOGIC
end_pwm:
    add  x12, x0, x0       # Reset pwm_counter
    addi x15, x15, 1       # breath_counter++
    
    slt  x28, x15, x14     # if breath_counter < breath_delay
    beq  x28, x0, breathe  # Time to change intensity!
    jal  x0, check_btns    # Not time yet, just check buttons

breathe:
    add  x15, x0, x0       # Reset breath_counter
    beq  x16, x0, dimming  # if breath_dir == 0, go to dimming

brightening:
    add  x11, x11, x17     # T_high += breath_step
    slt  x28, x11, x13     # if T_high < max_intensity
    beq  x28, x0, swap_dim # Hit ceiling, swap direction
    jal  x0, check_btns

swap_dim:
    add  x11, x0, x13      # Clamp T_high to max_intensity
    add  x16, x0, x0       # breath_dir = 0 (Start dimming)
    jal  x0, check_btns

dimming:
    slt  x28, x11, x17      # if T_high < 0 (Underflow check)
    beq  x28, x0, safe_dim # If valid, move on
    add  x11, x0, x0       # Clamp T_high to 0
    addi x16, x0, 1        # breath_dir = 1 (Start brightening)
	jal x0, check_btns
	
safe_dim:
    sub  x11, x11, x17     # T_high -= breath_step

# BUTTON DEBOUNCING & CONTROL
check_btns:
    add  x21, x0, x31      # Read buttons from x31[span_6](end_span)
    xori x23, x20, -1      # NOT prev_state
    and  x22, x21, x23     # just_pressed = current AND (NOT prev)
    add  x20, x0, x21      # Update prev_state

btn_0:
    # INCREASE SPEED (Decrease breath_delay)
    andi x24, x22, 1
    beq  x24, x0, btn_1
    slt  x28, x14, x25     # Prevent going below 0
    beq  x28, x0, safe_dec_speed
    addi x14, x0, 2        # Clamp to a minimum delay
	jal x0, btn_1
	
safe_dec_speed:
	sub x14, x14, x25

btn_1:
    # DECREASE SPEED (Increase breath_delay)
    andi x24, x22, 2
    beq  x24, x0, btn_2
    add  x14, x14, x25     # breath_delay += speed_step

btn_2:
    # INCREASE MAX INTENSITY
    andi x24, x22, 4
    beq  x24, x0, btn_3
    add  x13, x13, x26     # max_intensity += intensity_step
    slt  x28, x10, x13     # if T_total < max_intensity
    beq  x28, x0, btn_3
    add  x13, x0, x10      # Clamp to T_total (100%)

btn_3:
    # DECREASE MAX INTENSITY
    andi x24, x22, 8
    beq  x24, x0, end_cycle
    slt  x28, x13, x26     # Prevent underflow
    beq  x28, x0, safe_dec_intensity
    addi x13, x0, 10       # Clamp to a minimum intensity
	jal x0, end_cycle
	
safe_dec_intensity:
    sub  x13, x13, x26     # max_intensity -= intensity_step

end_cycle:
    jal  x0, main_loop     # Return to start of PWM