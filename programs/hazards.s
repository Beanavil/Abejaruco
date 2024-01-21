# Instruction                   Binary                                Hex

## NOP                                                                         1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
li $r1 <- 2                     000000000010  00000 001 00001 0000011 00201083 F F F F F F D E M W
                                           2     0   0     r1   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011 00101103             F D E M  W
                                           1     0   0     r2   Itype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033               F D E  M  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                 F D  E  M  W
                                    add    r0    r0   0    r0   Rtype

## Data hazard
add $r2 <- $r1, $r1             0000000 00001 00001 000 00010 0110011 00108133                   F  D  E  M  W
                                    add    r1    r1   0    r2   Rtype
add $r3 <- $r2, $r2             0000000 00010 00010 000 00011 0110011 002101B3                      F  D  D  D  E  M  W
                                    add    r2    r2   0    r3   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                         F  F  F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                  F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype

## Load-use hazard
ldw  $r4 <- 0($r1)               000000000000 00001 010 00100 0000011 0000A203                                     F  D  E  M  W
                                            0    r1   w    r4   Itype
add $r5 <- $r4, $r4             0000000 00100 00100 000 00101 0110011 004202B3                                        F  D  D  D  E  M  W
                                    add    r4    r4   0    r5   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                           F  F  F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                    F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype

## Store-use hazard
add $r2 <- $r1, $r1             0000000 00001 00001 000 00010 0110011 00108133                                                       F  F  F  F  F  F  D  E  M  W
                                    add    r1    r1   0    r2   Rtype
stw  0($r3) <- $r2              0000000 00010 00011 010 00000 0100011 0021A023                                                                         F  D  D  D  E  M  W
                                      0    r2    r3   w     0   Stype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                                            F  F  F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                                                     F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype

## No hazard
add $r4 <- $r1, $r1             0000000 00001 00001 000 00100 0110011 00108233                                                                                        F  F  F  F  F  F  D  E  M  W
                                    add    r1    r1   0    r4   Rtype
add $r5 <- $r3, $r3             0000000 00011 00011 000 00101 0110011 003182B3                                                                                                          F  D  E  M  W
                                    add    r3    r3   0    r5   Rtype
add $r0 <- $r0, $r0             0000000 00000 00000 000 00000 0110011 00000033                                                                                                             F  D  E  M  W
                                    add    r0    r0   0    r0   Rtype