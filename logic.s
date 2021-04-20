initial_regs:
    addi	$r1, $r0, 1			# $r1 = $r0 + 1
    addi	$r2, $r0, -1			# $r2 = $r0 + -1
    addi    $r4, $r0, 2
    addi    $r24, $r0, 12
    addi	$r25, $r0, 15			# $r25 = $r0 + 15
initial_game:                       # make ball movement reg
    add     $r22,   $r5,   $r0      # initialize ball x
    add     $r23,   $r6,   $r0     # initialize ball y
    add     $r15,   $r5,    $r0
    add     $r16,   $r6,    $r0
    addi	$r26, $r0, 1			# $r26 = $r0 + 1
    addi	$r27, $r0, 1			# $r27 = $r0 + 1
checking_stall:
    bne     $r3,    $r0,    wait_for_neg
checking_stall_0:
    bne     $r3,    $r1,    wait_for_neg_1
    #stall   $r3,   $r0,   1   # stall while $r3 != 1
    j		game				# jump to game
wait_for_neg:
    nop
    j   checking_stall
wait_for_neg_1:
    nop
    j		checking_stall_0				# jump to checking_stall_0
game:                               # GAME LOOP
    j		move_ball_x				# jump to move_ball_x
check_cont:
    bne     $r21,    $r0,    end_game
    j		checking_stall				# jump to checking_stall
move_ball_x:                        # BALL BASIC MOVEMENT
    mul     $r28,   $r26,    $r4    # amt move = xdir * ball mvmt change
    add     $r29,   $r29,   $r28    # apply change to ball_x
    and     $r22,   $r1,    $r0
    add     $r22,   $r29,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r28,   $r0,    $r28    #reset the math reg
    j		move_ball_y				# jump to move_ball_y
move_ball_y:
    mul     $r28,   $r27,   $r4     #should we add noop LOL
    add     $r30,   $r30,   $r28
    and     $r23,   $r1,    $r0
    add     $r23,   $r30,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r28,   $r0,    $r28    #reset the math reg
    j		ball_handle				# jump to ball_handle
ball_handle:                                    # HANDLING AUTOMATIC BALL MVMT
    # checking wall collisions for ball
    blt     $r16,   $r25,    ball_flip_y     #check if ball hit top
    nop
    nop
    nop
    bgt     $r16,   $r12,   ball_flip_y     #check if ball hit bottom
    nop
    nop
    nop
    blt     $r15,   $r24,    ball_left_edge
    nop
    nop
    nop
    bgt     $r15,   $r11,    ball_right_edge
    nop
    nop
    nop
    mul     $r26,   $r26,   $r13
    mul     $r27,   $r27,   $r14  
ball_left_edge:                     # HITTING LEFT OR RIGHT EDGE AND CHECKING IF WIN OR NOT
    and     $r28,   $r0,   $r28
    addi    $r28,   $r30,   -15      # r28 = ball top
    blt     $r28,   $r7,    ball_flip_x     #check if ball top < segment top then bounce
    and     $r28,   $r0,   $r28
    addi    $r28,   $r30,   15      # r28 = ball bott
    blt     $r8,   $r28,    ball_flip_x     #check if seg bot < ball bot then bounce
    j       left_lose   # ball hit in segment
ball_right_edge:
    and     $r28,   $r0,   $r28
    addi    $r28,   $r30,   -15      # r28 = ball top
    blt     $r28,   $r9,    ball_flip_x     #check if ball top < segment top then bounce
    and     $r28,   $r0,   $r28
    addi    $r28,   $r30,   15      # r28 = ball bott
    blt     $r10,   $r28,    ball_flip_x     #check if seg bot < ball bot then bounce
    j       right_lose   # ball hit in segment
ball_flip_x:                        # BALL DIRECTION CHANGE
    mul     $r26,   $r26,  $r2
    j		check_cont              # jump to beq check (loop)
    
ball_flip_y:
    mul     $r27,   $r27,   $r2
    j		check_cont				# jump to paddle_handle
left_lose:      # HIT GOAL
    addi     $r21,    $r21,     2
right_lose:
    addi     $r21,    $r21,    1
end_game:
    nop

# top left is 0, 0
# CONSTANTS
# r1=1, $r2=-1 
# $r4 = ball movement change

# INPUT
# $r3 = posEdgeScreenEnd -> =1 when posEdge aka stop stalling. =0 else. can only read from this
# $r5, $r6 = initial ball x, y # can use after initilization
# $r7, $r8 = left edge goal top ycoord, bottom ycoord
# $r9, $r10 = right edge goal top ycoord, bottom ycoord
# $r11, $r12 = ball xlim, ylim
# $r13 = x dir change from VGAController (paddle collision)
# $r14 = y dir change from VGA Controller
# $r17-$r20 
# $r24, $r25 = ball lowerxlim, ylim (10,15)
# $r26, $r27 = ball xdir, ydir
# $r28 = calculating change of ball in any dir (temporary storage)

# OUTPUT
# $r21 = winner (0 none, 1 p1, 2 p2)
# $r22, $r23 = ball x,y
# $r15, $r16 = temporary hold for ball x and y