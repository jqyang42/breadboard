# top left is 0, 0
# r1=1, $r2=-1 
# $r3 = winner (1 player 1, 2 player 2)
# $r4=4
# $r5 = player 1 paddle bounds
# $r6 = player 2 paddle bounds
# $r7, $r8 = left edge goal top ycoord, bottom ycoord
# $r9, $r10 = right edge goal top ycoord, bottom ycoord
# $r11, $r12 = paddle_1 x, y
# $r13, $r14 = paddle_2 x,y
# $r15, $r16 = ball x, y
# $r17, $r18 = ball direction x, y
# $r19, $r20 = width, heaight of screen
# $r21 = ball movement change
# $r22 = player1 press up - vga controller called in processor, directly connect wire to register
# $r23 = player1 press down
# $r24 = player1 press left
# $r25 = plauer1 press right
# $r26 = player2 press up
# $r27 = player2 press down
# $r28 = player2 press left
# $r29 = plauer2 press right

#
# PLAYER PADDLE MOVEMENT
#
move_player1_up:
    addi    $r12,    -5
    and     $r22,   $r0
    j		p1_down				# jump to 120
move_player1_down:
    addi    $r12,    5
    and     $r23,   $r0
    j		p1_up				# jump to p1_up
move_player2_up:
    addi    $r14,    -5
    and     $r26,   $r0
    j		p2_down				# jump to p2_down
move_player2_down:
    addi    $r14,    5
    and     $r27,   $r0
    j		p2_left				# jump to p2_left   
move_player1_left:
    addi    $r11,    -5
    and     $r24,   $r0
    j		p1_right				# jump to p1_right  
move_player1_right:
    bgt     $r11,   $r5,    p2_up
    addi    $r11,    5
    and     $r25,   $r0
    j		p2_up				# jump to p2_up
move_player2_left:
    blt     $r13,   $r6,    p2_right
    addi    $r13,    -5
    and     $r28,   $r0
    j		p2_right				# jump to p2_right
    

move_player2_right:
    addi    $r13,    5
    and     $r29,   $r0
    j		after_paddle				# jump to after_paddle

#
# BALL BASIC MOVEMENT
#
move_ball_x:
    mul     $r21,   $r4,   $r17     #should we add noop LOL
    addi    $r15,    $r21,   $r15
    and     $r21,   $r0,    $r21    #reset the math reg

move_ball_y:
    mul     $r21,   $r4,   $r18     #should we add noop LOL
    addi    $r16,   $r21,   $r16
    and     $r21,   $r0,    $r21    #reset the math reg

#
# BALL DIRECTION CHANGE
#
ball_flip_x:
    mul     $r17,   $r17,  $r2
    j		paddle_handle				# jump to paddle_handle
    
ball_flip_y:
    mul     $r18,   $r18,   $r2
    j		paddle_handle				# jump to paddle_handle

ball_left_edge:
    bgt     $r15,   $r8,    ball_flip_x     #check if ball hit left outside segment
    blt     $r15,   $r7,    ball_flip_x     #check if ball hit left outside segment
    j       left_lose

ball_right_edge:
    bgt     $r15,   $r10,    ball_flip_x     #check if ball hit left outside segment
    blt     $r15,   $r9,    ball_flip_x     #check if ball hit left outside segment
    j       right_lose

#
# HIT GOAL
#
left_lose:
    add     $r3,    $r1,    $r3
    add     $r3,    $r1,    $r3


right_lose:
    add     $r3,    $r1,    $r3


#
# HANDLING AUTOMATIC BALL MVMT
#
ball_handle:
    # checking wall collisions for ball
    blt     $r16,   $r0,    ball_flip_y     #check if ball hit top (make sure to not go to next line)
    bgt     $r16,   $r20,   ball_flip_y     #check if ball hit bottom (make sure to not go to next line)
    # ball left
    blt     $r15,   $r0,    ball_left_edge
    # ball right
    bgt     $r15,   $r19,    ball_right_edge
    j		paddle_handle				# jump to paddle_handle
    
#
# HANDLING PADDLE MVMT
#
paddle_handle:
    beq     $r22,   $r1,    move_player1_up
p1_down:
    beq     $r23,   $r1,    move_player1_down
p1_left:
    beq     $r24,   $r1,    move_player1_left
p1_right:
    beq     $r25,   $r1,    move_player1_right
p2_up:
    beq     $r26,   $r1,    move_player2_up
p2_down:
    beq     $r27,   $r1,    move_player2_down
p2_left:
    beq     $r28,   $r1,    move_player2_left
p2_right:
    beq     $r29,   $r1,    move_player2_right

#
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
game:
j   ball_handle
j   paddle_handle
after_paddle:
    beq     $r3,    $r0,    game
    j   end_game