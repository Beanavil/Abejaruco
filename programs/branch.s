# Instruction                   Binary                                Hex

                                                                                   1 2 3 4 5 6 7 8 9 10 11  12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
li $r1 <- 00100000               000000100000 00000 001 00001 0000011 02001083     F F F F F F D E C  W
                                            0     0 fun    r1   Itype
beq $r0, $r1, 10100           0 000001 00001 00000 000 0100 0 1100011 02100463                 F D D  D  E /*NOT TAKEN*/
                                 imm                  imm      branch
li $r2 <- 1                      000000000001 00000 001 00010 0000011 00101103                   F F  F  D   E  C  W
                                            1     0   0    r2   Itype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                           F   D  E  C  W
                                    add    r0    r0   0    r0   Rtype
10:
beq $r0, $r0, 10100           0 000010 00000 00000 000 0000 0 1100011 04000063                             F  F  F  F  F  F  D  E /*TAKEN*/
                                   imm   $r0   $r0 fun  imm    branch

add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                 F  D  n  n  n
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                    F  n  n  n  n
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                        /*DOES NOT EXECUTE*/
                                    add    r0    r0   0    r0   Rtype
20:
li $r3 <- 50                     000000110010 00011 001 00011 0000011 03219183                                                       F  F  F  F  D  E  C  W
                                            1     0   0    r3   Itype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                          F  D  E  C  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                             F  D  E  C  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                                F  D  E  C  W
                                    add    r0    r0   0    r0   Rtype