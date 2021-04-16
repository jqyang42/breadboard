# top left is 0, 0
# r1=1, $r2=-1 
# $r3 = winner (1 player 1, 2 player 2)
# $r4=4
# $r5 = 1-game over, 0-game not over
# $r6 = stall logic for game loop (0 when game should run. 1
# $r7, $r8 = left edge goal top ycoord, bottom ycoord
# $r9, $r10 = right edge goal top ycoord, bottom ycoord
# $r13, $r14 = initial ball x, y
# $r15, $r16 = ball x, y
# $r17, $r18 = ball direction x, y
# $r19, $r20 = ball x lim and y lim
# $r21 = ball movement change
# $r22, $r23 = ball x, y that are wired directly in regfile for wrapper :)
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
initial_game:
add     $r15,   $r13,   $r0
add     $r16,   $r14,   $r0     # initialize location of ball in registers  
add     $r22,   $r13,   $r0     
add     $r23,   $r14,   $r0    
game: 
j   ball_handle
check_cont:
bne     $r3,    $r0,    end_game
stall   $r11,    $r0,    $r6    #r11 is a random reg since we can't write to r6
j		game				# jump to game


#
# HANDLING AUTOMATIC BALL MVMT
#
ball_handle:
    # checking wall collisions for ball
    blt     $r16,   $r0,    ball_flip_y     #check if ball hit top (make sure to not go to next line)
    nop
    nop
    nop
    bgt     $r16,   $r20,   ball_flip_y     #check if ball hit bottom (make sure to not go to next line)
    nop
    nop
    nop
    # ball left
    blt     $r15,   $r0,    ball_left_edge
    nop
    nop
    nop
    # ball right
    bgt     $r15,   $r19,    ball_right_edge
    nop
    nop
    nop
    j		check_cont              # jump to beq check (loop)


#
# BALL BASIC MOVEMENT
#
move_ball_x:
    mul     $r21,   $r4,    $r17     #should we add noop LOL
    add     $r15,   $r21,   $r15
    add     $r22,   $r15,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r21,   $r0,    $r21    #reset the math reg

move_ball_y:
    mul     $r21,   $r4,   $r18     #should we add noop LOL
    add     $r16,   $r21,   $r16
    add     $r23,   $r16,   $r0     #writes the x to the reg that is directly connected to output of wrapper to use in VGAController
    and     $r21,   $r0,    $r21    #reset the math reg

#
# BALL DIRECTION CHANGE
#
ball_flip_x:
    mul     $r17,   $r17,  $r2
    j		check_cont              # jump to beq check (loop)
    
ball_flip_y:
    mul     $r18,   $r18,   $r2
    j		check_cont				# jump to paddle_handle

ball_left_edge:
    nop
    nop
    nop
    bgt     $r15,   $r8,    ball_flip_x     #check if ball hit left outside segment
    nop
    nop
    nop
    blt     $r15,   $r7,    ball_flip_x     #check if ball hit left outside segment
    j       left_lose

ball_right_edge:
    nop
    nop
    nop
    bgt     $r15,   $r10,    ball_flip_x     #check if ball hit left outside segment
    nop
    nop
    nop
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
end_game:
    add     $r5,    $r1,    $r5


