# top left is 0, 0
# CONSTANTS
# r1=1, $r2=-1 
# $r4 = ball movement change

# INPUT
# $r3 = posEdgeScreenEnd -> =1 when posEdge aka stop stalling. =0 else. can only read from this
# $r5, $r6 = initial ball x, y
# $r7, $r8 = left edge goal top ycoord, bottom ycoord
# $r9, $r10 = right edge goal top ycoord, bottom ycoord
# $r11, $r12 = ball xlim, ylim
# $r24, $r25 = ball lowerxlim, ylim (0,0 but account for ball size)
# $r26, $r27 = ball xdir, ydir
# $r13, $r14, $r15, $r16 = p1 paddle bounds (T, B, L, R)
# $r17, $r18, $r19, $r20 = p2 paddle bounds
# $r28 = calculating change of ball in any dir (temporary storage)

# OUTPUT
# $r21 = winner (0 none, 1 p1, 2 p2)
# $r22, $r23 = ball x,y
# $r29, $r30 = temporary hold for ball x and y

# ACTUAL GAME
#
nop
nop
nop
nop
nop
nop
nop
nop 
initial_regs:
    # make directions 1 adn -1
    addi	$r1, $r0, 1			# $r1 = $r0 + 1
    addi	$r2, $r0, -1			# $r2 = $r0 + -1
    addi    $r4, $r0, 2
    addi    $r24, $r0, 12
    addi	$r25, $r0, 15			# $r25 = $r0 + 15
    
# make ball movement reg
initial_game:
    add     $r22,   $r5,   $r0      # initialize ball x
    add     $r23,   $r6,   $r0     # initialize ball y
    add     $r29,   $r5,    $r0
    add     $r30,   $r6,    $r0
    addi	$r26, $r0, 1			# $r26 = $r0 + 1
    addi	$r27, $r0, 1			# $r27 = $r0 + 1

checking_stall:
    beq     $r3,    $r1,    wait_for_neg
    stall   $r3,   $r0,   1   # stall while $r3 != 1
    j		game				# jump to game
wait_for_neg:
    nop
    j   checking_stall

#
# GAME LOOP
#
game: 
    j		move_ball_x				# jump to move_ball_x
check_cont:
    bne     $r21,    $r0,    end_game
    j		checking_stall				# jump to checking_stall

#
# BALL BASIC MOVEMENT
#
move_ball_x:
    mul     $r28,   $r26,    $r4    #amt move = xdir * ball mvmt change
    add     $r29,   $r29,   $r28    # apply change to ball_x
    add     $r22,   $r29,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r28,   $r0,    $r28    #reset the math reg
    j		move_ball_y				# jump to move_ball_y
    

move_ball_y:
    mul     $r28,   $r27,   $r4     #should we add noop LOL
    add     $r30,   $r30,   $r28
    add     $r23,   $r30,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r28,   $r0,    $r28    #reset the math reg
    j		ball_handle				# jump to ball_handle
    
#
# HANDLING AUTOMATIC BALL MVMT
#
ball_handle:
    # checking wall collisions for ball
    blt     $r23,   $r25,    ball_flip_y     #check if ball hit top
    nop
    nop
    nop
    bgt     $r23,   $r12,   ball_flip_y     #check if ball hit bottom
    nop
    nop
    nop
    blt     $r22,   $r24,    ball_left_edge
    nop
    nop
    nop
    bgt     $r22,   $r11,    ball_right_edge
    nop
    nop
    nop
    #checking paddle collisons
# PLAYER 1 LEFT COLLISION WITH BALL
check_p1_left:
    # if b_right >= p1_left
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   10     # $r28 = right edge of ball
    bgt     $r28,   $r15,   check_p1L_1
    j		check_p1_right				# jump to check_p1_right
check_p1L_1:
    # if b_right >= p1_left && b_left < p1_left
    and     $r28,   $r0,    $r28   
    addi    $r28,   $r22,   -10      # r28 = left edge
    blt     $r28,   $r15,   check_p1L_type1
    j		check_p1_right				# jump to check_p1_right 
check_p1L_type1:
    # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r13,   check_p1L_type1_1
    j		check_p1L_type2				# jump to check_p1L_type2
check_p1L_type1_1:
     # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top && p1_top < b1_bot
            # flip x dir (it is a left p1 hit)
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r13,   $r28,   ball_flip_x
    j		check_p1L_type2				# jump to check_p1L_type2
check_p1L_type2:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r14,   $r28,   check_p1L_type2_1
    j		check_p1L_type3				# jump to check_p1L_type3
check_p1L_type2_1:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot && b_top < p1_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r13,   ball_flip_x
    j		check_p1L_type3				# jump to check_p1L_type3
check_p1L_type3:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r28,   $r13,   check_p1L_type3_1
    j		check_p1_right				# jump to check_p1_right
check_p1L_type3_1:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top && p1_bot >= b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r14,   $r28,   ball_flip_x
    j		check_p1_right				# jump to check_p1_right
    
# PLAYER 1 RIGHT COLLISION WITH BALL
check_p1_right:
    # if p1_right >= b_left
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   -10     # $r28 = left edge of ball
    bgt     $r16,   $r28,   check_p1R_1
    j		check_p1_top				# jump to check_p1_top
check_p1R_1:
    # if p1_right >= b_left && p1_right < b_right
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   10     # $r28 = right edge of ball
    blt     $r16,   $r28,   check_p1R_type1
    j		check_p1_top				# jump to check_p1_top
check_p1R_type1:
    # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r13,   check_p1R_type1_1
    j		check_p1R_type2				# jump to check_p1L_type2
check_p1R_type1_1:
     # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top && p1_top < b1_bot
            # flip x dir (it is a left p1 hit)
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r13,   $r28,   ball_flip_x
    j		check_p1R_type2				# jump to check_p1L_type2
check_p1R_type2:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r14,   $r28,   check_p1R_type2_1
    j		check_p1R_type3				# jump to check_p1L_type3
check_p1R_type2_1:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot && b_top < p1_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r13,   ball_flip_x
    j		check_p1R_type3				# jump to check_p1L_type3
check_p1R_type3:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r28,   $r13,   check_p1R_type3_1
    j		check_p1_top				# jump to check_p1_top
check_p1R_type3_1:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top && p1_bot >= b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r14,   $r28,   ball_flip_x
    j		check_p1_top 			# jump to check_p1_top

# PLAYER 1 TOP COLLISION WITH BALL
check_p1_top:
    # if b_bot >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r28,   $r13,   check_p1T_1
    j		check_p1_bot 			# jump to check_p1_bot
check_p1T_1:
    # if b_bot >= p1_top && btop < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r13,   check_p1T_type1
    j		check_p1_bot 			# jump to check_p1_bot
check_p1T_type1:
    # if p1_top >= b_bot && btop < p1_top
        # if p1_left < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r15,   $r28,   check_p1T_type1_1
    j		check_p1T_type2 			# jump to check_p1_bot
check_p1T_type1_1:
    # if p1_top >= b_bot && btop < p1_top   
        # if p1_left < b_right && b_left < p1_left
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r15,   ball_flip_y
    j		check_p1T_type2 			# jump to check_p1_bot
check_p1T_type2:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r16,   check_p1T_type2_1
    j		check_p1T_type3			# jump to check_p1_type3
check_p1T_type2_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right && p1_right < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r16,   $r28,   ball_flip_y
    j		check_p1T_type3			# jump to check_p1_type3
check_p1T_type3:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    bgt     $r28,   $r15,   check_p1T_type3_1
    j		check_p1_bot			# jump to check_p1_bot
check_p1T_type3_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left && p1_right >= b_right
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    bgt     $r16,   $r28,   ball_flip_y
    j		check_p1_bot			# jump to check_p1_type3

# PLAYER 1 BOTTOM COLLISION WITH BALL
check_p1_bot: 
    # if p1_bot >= b_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r14,   $r28,   check_p1B_1
    j		check_p2_left			# NO COLLISIONS WITH P1, CHECK P2
check_p1B_1:
    # if p1_bot >= b_top && p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r14,   $r28,   check_p1B_type1
    j		check_p2_left 			# NO COLLISIONS WITH P1, CHECK P2
check_p1B_type1:
    # if p1_top >= b_bot && btop < p1_top
        # if p1_left < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r15,   $r28,   check_p1B_type1_1
    j		check_p1B_type2 			# jump to check_p1_bot
check_p1B_type1_1:
    # if p1_top >= b_bot && btop < p1_top   
        # if p1_left < b_right && b_left < p1_left
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r15,   ball_flip_y
    j		check_p1B_type2 			# jump to check_p1_bot
check_p1B_type2:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r16,   check_p1B_type2_1
    j		check_p1B_type3			# jump to check_p1_type3
check_p1B_type2_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right && p1_right < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r16,   $r28,   ball_flip_y
    j		check_p1B_type3			# jump to check_p1_type3
check_p1B_type3:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    bgt     $r28,   $r15,   check_p1B_type3_1
    j		check_p2_left 			# NO COLLISIONS WITH P1, CHECK P2
check_p1B_type3_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left && p1_right >= b_right
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    bgt     $r16,   $r28,   ball_flip_y
    j		check_p2_left 			# NO COLLISIONS WITH P1, CHECK P2

#
# PLAYER 2 PADDLE BALL COLLISIONS
#
# PLAYER 2 LEFT COLLISION WITH BALL
check_p2_left:
    # if b_right >= p2_left
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   10     # $r28 = right edge of ball
    bgt     $r28,   $r19,   check_p2L_1
    j		check_p2_right				# jump to check_p1_right
check_p2L_1:
    # if b_right >= p1_left && b_left < p1_left
    and     $r28,   $r0,    $r28   
    addi    $r28,   $r22,   -10      # r28 = left edge
    blt     $r28,   $r19,   check_p2L_type1
    j		check_p2_right				# jump to check_p1_right 
check_p2L_type1:
    # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r17,   check_p2L_type1_1
    j		check_p2L_type2				# jump to check_p1L_type2
check_p2L_type1_1:
     # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top && p1_top < b1_bot
            # flip x dir (it is a left p1 hit)
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r17,   $r28,   ball_flip_x
    j		check_p2L_type2				# jump to check_p1L_type2
check_p2L_type2:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r18,   $r28,   check_p2L_type2_1
    j		check_p2L_type3				# jump to check_p1L_type3
check_p2L_type2_1:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot && b_top < p1_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r18,   ball_flip_x
    j		check_p2L_type3				# jump to check_p1L_type3
check_p2L_type3:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r28,   $r17,   check_p2L_type3_1
    j		check_p2_right				# jump to check_p1_right
check_p2L_type3_1:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top && p1_bot >= b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r18,   $r28,   ball_flip_x
    j		check_p2_right				# jump to check_p1_right
    
# PLAYER 2 RIGHT COLLISION WITH BALL
check_p2_right:
    # if p1_right >= b_left
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   -10     # $r28 = left edge of ball
    bgt     $r20,   $r28,   check_p2R_1
    j		check_p2_top				# jump to check_p1_top
check_p2R_1:
    # if p1_right >= b_left && p1_right < b_right
    and     $r28,   $r0,    $r28 
    addi    $r28,   $r22,   10     # $r28 = right edge of ball
    blt     $r20,   $r28,   check_p2R_type1
    j		check_p2_top				# jump to check_p1_top
check_p2R_type1:
    # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r17,   check_p2R_type1_1
    j		check_p2R_type2				# jump to check_p1L_type2
check_p2R_type1_1:
     # if b_right >= p1_left && b_left < p1_left
        # if b_top < p1_top && p1_top < b1_bot
            # flip x dir (it is a left p1 hit)
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r17,   $r28,   ball_flip_x
    j		check_p2R_type2				# jump to check_p1L_type2
check_p2R_type2:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r18,   $r28,   check_p2R_type2_1
    j		check_p2R_type3				# jump to check_p1L_type3
check_p2R_type2_1:
    # if b_right >= p1_left && b_left < p1_left
        # if p1_bot < b_bot && b_top < p1_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r18,   ball_flip_x
    j		check_p2R_type3				# jump to check_p1L_type3
check_p2R_type3:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r28,   $r17,   check_p2R_type3_1
    j		check_p2_top				# jump to check_p1_top
check_p2R_type3_1:
    # if b_right >= p1_left && b_left < p1_left
        # b_top >= p1_top && p1_bot >= b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r18,   $r28,   ball_flip_x
    j		check_p2_top 			# jump to check_p1_top

# PLAYER 1 TOP COLLISION WITH BALL
check_p2_top:
    # if b_bot >= p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    bgt     $r28,   $r17,   check_p2T_1
    j		check_p2_bot 			# jump to check_p1_bot
check_p2T_1:
    # if b_bot >= p1_top && btop < p1_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    blt     $r28,   $r12,   check_p2T_type1
    j		check_p2_bot 			# jump to check_p1_bot
check_p2T_type1:
    # if p1_top >= b_bot && btop < p1_top
        # if p1_left < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r19,   $r28,   check_p2T_type1_1
    j		check_p2T_type2 			# jump to check_p1_bot
check_p2T_type1_1:
    # if p1_top >= b_bot && btop < p1_top   
        # if p1_left < b_right && b_left < p1_left
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r19,   ball_flip_y
    j		check_p2T_type2 			# jump to check_p1_bot
check_p2T_type2:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r20,   check_p2T_type2_1
    j		check_p2T_type3			# jump to check_p1_type3
check_p2T_type2_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right && p1_right < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r20,   $r28,   ball_flip_y
    j		check_p2T_type3			# jump to check_p1_type3
check_p2T_type3:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    bgt     $r28,   $r19,   check_p2T_type3_1
    j		check_p1_bot			# jump to check_p1_bot
check_p2T_type3_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left && p1_right >= b_right
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    bgt     $r20,   $r28,   ball_flip_y
    j		check_p2_bot			# jump to check_p1_type3

# PLAYER 1 BOTTOM COLLISION WITH BALL
check_p2_bot: 
    # if p1_bot >= b_top
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   -15      #r28 = ball top
    bgt     $r18,   $r28,   check_p2B_1
    j		check_cont 			# NO COLLISIONS 
check_p2B_1:
    # if p1_bot >= b_top && p1_bot < b_bot
    and     $r28,   $r0,    $r28
    addi    $r28,   $r23,   15      #r28 = ball bottom
    blt     $r18,   $r28,   check_p2B_type1
    j		check_cont 			# NO COLLISIONS 
check_p2B_type1:
    # if p1_top >= b_bot && btop < p1_top
        # if p1_left < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r19,   $r28,   check_p2B_type1_1
    j		check_p2B_type2 			# jump to check_p1_bot
check_p2B_type1_1:
    # if p1_top >= b_bot && btop < p1_top   
        # if p1_left < b_right && b_left < p1_left
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r19,   ball_flip_y
    j		check_p2B_type2 			# jump to check_p1_bot
check_p2B_type2:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    blt     $r28,   $r20,   check_p2B_type2_1
    j		check_p2B_type3			# jump to check_p1_type3
check_p2B_type2_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left < p1_right && p1_right < b_right
    and     $r28,   $r0,    $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    blt     $r20,   $r28,   ball_flip_y
    j		check_p2B_type3			# jump to check_p1_type3
check_p2B_type3:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   -10      #r28 = ball left
    bgt     $r28,   $r19,   check_p2B_type3_1
    j		check_cont 			# NO COLLISIONS 
check_p2B_type3_1:
    # if p1_top >= b_bot && btop < p1_top
        # if b_left >= p1_left && p1_right >= b_right
    and     $r28,   $r0,   $r28
    addi    $r28,   $r22,   10      #r28 = ball right
    bgt     $r20,   $r28,   ball_flip_y
    j		check_cont 			# NO COLLISIONS 

#
# HITTING LEFT OR RIGHT EDGE AND CHECKING IF WIN OR NOT
#
ball_left_edge:
    and     $r28,   $r0,   $r28
    addi    $r28,   $r23,   -15      # r28 = ball top
    blt     $r28,   $r7,    ball_flip_x     #check if ball top < segment top then bounce
    and     $r28,   $r0,   $r28
    addi    $r28,   $r23,   15      # r28 = ball bott
    blt     $r8,   $r28,    ball_flip_x     #check if seg bot < ball bot then bounce
    j       left_lose   # ball hit in segment
ball_right_edge:
    and     $r28,   $r0,   $r28
    addi    $r28,   $r23,   -15      # r28 = ball top
    blt     $r28,   $r9,    ball_flip_x     #check if ball top < segment top then bounce
    and     $r28,   $r0,   $r28
    addi    $r28,   $r23,   15      # r28 = ball bott
    blt     $r10,   $r28,    ball_flip_x     #check if seg bot < ball bot then bounce
    j       right_lose   # ball hit in segment

#
# BALL DIRECTION CHANGE
#
ball_flip_x:
    mul     $r26,   $r26,  $r2
    j		check_cont              # jump to beq check (loop)
    
ball_flip_y:
    mul     $r27,   $r27,   $r2
    j		check_cont				# jump to paddle_handle

#
# HIT GOAL
#
left_lose:
    addi     $r21,    $r21,     2
right_lose:
    addi     $r21,    $r21,    1
end_game:
    nop