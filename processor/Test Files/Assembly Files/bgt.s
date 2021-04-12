nop 	# simple blt test case
nop 
nop 
nop
nop
nop
addi    $r1, $r0, 5     # $r1 = 5
addi    $r2, $r0, 4     # $r2 = 4
sub     $r3, $r0, $r1   # $r3 = -5
sub     $r4, $r0, $r2   # $r4 = -4
nop
nop
nop 	
bgt 	$r1, $r2, b3	# r1 > r2 --> taken
nop			# flushed instruction
nop			# flushed instruction
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
b3: 
addi $r10, $r10, 1	# r10 += 1 (Correct)
bgt $r2, $r2, b4	# r2 == r2 --> not taken
nop			# nop in case of flush
nop			# nop in case of flush
nop			# Spacer 
addi $r10, $r10, 1	# r10 += 1 (Correct) 
b4: 			# Landing pad for branch
nop			
bgt $r1, $r4, b5	# r1 > r4 --> taken
nop			# flushed instruction
nop			# flushed instruction
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
b5: 
addi $r10, $r10, 1	# r10 += 1 (Correct)
bgt $r2, $r1, b6	# r2 < r1 --> not taken
nop			# nop in case of flush
nop			# nop in case of flush
nop			# Spacer
addi $r10, $r10, 1	# r10 += 1 (Correct) 
b6: 
nop			
bgt $r4, $r3, b7	# r4 > r3 --> taken
nop			# flushed instruction
nop			# flushed instruction
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
addi $r20, $r20, 1	# r20 += 1 (Incorrect)
b7: 
addi $r10, $r10, 1	# r10 += 1 (Correct)
bgt $r3, $r4, b8	# r3 < r4 --> not taken
nop			# nop in case of flush
nop			# nop in case of flush
nop			# Spacer
addi $r10, $r10, 1	# r10 += 1 (Correct) 
b8: 
nop			# Landing pad for branch
nop			# Avoid add RAW hazard
nop			
# Final: $r10 should be 6, $r20 should be 0