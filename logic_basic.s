initial_regs:
addi	$r1, $r0, 1			# $r1 = $r0 + 1
addi	$r2, $r0, -1			# $r2 = $r0 + -1
addi    $r4, $r0, 1
addi    $r24, $r0, 12           # $r24 = left xlim of ball
addi	$r25, $r0, 17			# $r25 = top ylim of ball
addi    $r12, $r0, 463          # $r12 = bottom ylim of ball
addi    $r11, $r0, 628          # $r11 = right xlim of ball
addi    $r26, $r0, 1
addi    $r27, $r0, 1
initial_game:                       # make ball movement reg
addi     $r22,   $r0,   320      # initialize ball x
addi     $r23,   $r0,   240     # initialize ball y
addi     $r15,   $r0,   320
addi     $r16,   $r0,   240
move_ball_x:                        # BALL BASIC MOVEMENT
mul     $r28,   $r26,   $r4    # amt move = xdir * ball mvmt change
add     $r15,   $r15,   $r28    # apply change to ball_x
add     $r22,   $r15,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
and     $r28,   $r0,    $r28    #reset the math reg
move_ball_y:
mul     $r28,   $r27,   $r4     #should we add noop LOL
add     $r16,   $r16,   $r28
add     $r23,   $r16,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
and     $r28,   $r0,    $r28    #reset the math reg
ball_handle:                                    # HANDLING AUTOMATIC BALL MVMT
# checking wall collisions for ball                                     
blt     $r16,   $r25,    ball_flip_y     #check if ball hit top         #31
bgt     $r16,   $r12,   ball_flip_y     #check if ball hit bottom       #35
blt     $r15,   $r24,    ball_flip_x                                #39
bgt     $r15,   $r11,    ball_flip_x                               #43    
j		checking_stall_0				# jump to check_cont
ball_flip_x:                        # BALL DIRECTION CHANGE
mul     $r26,   $r26,  $r2                                              #64
j		checking_stall_0              # jump to beq check (loop)
ball_flip_y:
mul     $r27,   $r27,   $r2                                             #66
j		checking_stall_0				# jump to paddle_handle
checking_stall_0:
bne     $r3,    $r1,    checking_stall_0_1
j		move_ball_x				# move again
checking_stall_0_1:
bne     $r3,    $r1,    checking_stall_0
j		move_ball_x				# move again

