# Instruction                   Binary                                Hex

## NOP                                                                          1 2 3 4 5 6 7 8 9 10 11  12 13 14   15  16  17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
li $r1 <- 00100000              000000100000 00000 001 00001 0000011  02001083  F F F F F F D E M W
                                           0     0 fun    r1   Itype
j  0($r1)                       000000000000 00001 000 00000 1100111  00008067              F D D  D E
                                         imm     1 fun   imm   Itype
li $r2 <- 1                     000000000001 00000 001 00010 0000011  00101103                F F  F D nop nop nop nop nop
                                           1     0   0    r2   Itype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                       F   D   E   C  W
                                    add    r0    r0   0    r0   Rtype
20:
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
30:
li $r3 <- 50                    000000110010 00011 001 00011 0000011  03219183
                                           1     0   0    r3   Itype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033
                                    add    r0    r0   0    r0   Rtype