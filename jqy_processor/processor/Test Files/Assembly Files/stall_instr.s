stall $r15, $r0, 0   # stall if $r15 != 0 --> not stalling
stall $r15, $r0, 1   # stall if $r15 != 1 --> stall!
addi $r2, $r2, 5    # $r2 = 5