initial_regs:
addi	$r1, $r0, 1			# $r1 = $r0 + 1                                 #0
addi	$r2, $r0, -1			# $r2 = $r0 + -1
addi    $r4, $r0, 10
addi    $r24, $r0, 12
addi	$r25, $r0, 15			# $r25 = $r0 + 15
addi    $r26, $r0, 1
addi    $r27, $r0, 1
initial_game:                       # make ball movement reg
addi     $r22,   $r0,   320      # initialize ball x                        #7
addi     $r23,   $r0,   240     # initialize ball y
addi     $r15,   $r0,   320
addi     $r16,   $r0,   240
move_ball_x:                        # BALL BASIC MOVEMENT
mul     $r28,   $r26,   $r4    # amt move = xdir * ball mvmt change         #11
add     $r15,   $r15,   $r28    # apply change to ball_x
add     $r22,   $r15,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
and     $r28,   $r0,    $r28    #reset the math reg
move_ball_y:
mul     $r28,   $r27,   $r4     #should we add noop LOL                     #15
add     $r16,   $r16,   $r28
add     $r23,   $r16,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
and     $r28,   $r0,    $r28    #reset the math reg
checking_stall_0:
bne     $r3,    $r1,    checking_stall_0_1                                  #19
nop
nop
nop
j		move_ball_x				# move again
checking_stall_0_1:
bne     $r3,    $r1,    checking_stall_0                                    #24
nop
nop
nop
j		move_ball_x				# move again

