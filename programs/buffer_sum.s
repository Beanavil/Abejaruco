# Instruction                               Binary                              Hex

li $r1 <- 10110001                      00010110000  00000 001 00001 0000011    0B001083
                                                  2     0   0     r1   Itype
li $r2 <- 110010                        00000110001  00000 001 00010 0000011    03101103
                                                  2     0   0     r2   Itype
li $r3 <- 0                             00000000000  00000 001 00011 0000011    00001183
                                                  2     0   0     r2   Itype
li $r25 <- 10000                        00000010000  00000 001 11001 0000011    01001C83
                                                  2     0   0    r25  Itype
beq $r1, $r2, 10100000                0 01010 00001 00011 000 0000 0 1100011    14118063
                                          imm                  imm    branch
lb $r4 <-  000000 ($r2)                 0000000000  00010 000 00100 0000011     00010203
                                                  0    r3   0     r4   Itype
lb $r5 <-  000100 ($r2)                 0000000100  00010 000 00101 0000011     00410283
                                                  0    r3   0     r5   Itype
lb $r6 <-  001000 ($r2)                 0000001000  00010 000 00110 0000011     00810303
                                                  0    r3   0     r6   Itype
lb $r7 <-  001100 ($r2)                 0000001100  00010 000 00111 0000011     00C10383
                                                  0    r3   0     r7   Itype
lb $r8 <-  010000 ($r2)                 0000010000  00010 000 01000 0000011     01010403
                                                  0    r3   0     r8   Itype
lb $r9 <-  010100 ($r2)                 0000010100  00010 000 01001 0000011     01410483
                                                  0    r3   0     r9   Itype
lb $r10 <- 011000 ($r2)                 0000011000  00010 000 01010 0000011     01810503
                                                  0    r3   0    r10   Itype
lb $r11 <- 011100 ($r2)                 0000011100  00010 000 01011 0000011     01C10583
                                                  0    r3   0    r11   Itype
lb $r12 <- 100000 ($r2)                 0000100000  00010 000 01100 0000011     02010603
                                                  0    r3   0    r12   Itype
lb $r13 <- 100100 ($r2)                 0000100100  00010 000 01101 0000011     02410683
                                                  0    r3   0    r13   Itype
lb $r14 <- 101000 ($r2)                 0000101000  00010 000 01110 0000011     02810703
                                                  0    r3   0    r14   Itype
lb $r15 <- 101100 ($r2)                 0000101100  00010 000 01111 0000011     02C10783
                                                  0    r3   0    r15   Itype
lb $r16 <- 110000 ($r2)                 0000110000  00010 000 10000 0000011     03010803
                                                  0    r3   0    r16   Itype
lb $r17 <- 110100 ($r2)                 0000110100  00010 000 10001 0000011     03410883
                                                  0    r3   0    r17   Itype
lb $r18 <- 111000 ($r2)                 0000111000  00010 000 10010 0000011     03810903
                                                  0    r3   0    r18   Itype
lb $r19 <- 111100 ($r2)                 0000111100  00010 000 10011 0000011     03C10983
                                                  0    r3   0    r19   Itype
add $r3 <- $r3, $r4                     0000000 00100 00011 000 00011 0110011   004181B3
                                           add    r4    r3   0    r3   Rtype
add $r3 <- $r3, $r5                     0000000 00101 00011 000 00011 0110011   005181B3
                                           add    r5    r3   0    r3   Rtype
add $r3 <- $r3, $r6                     0000000 00110 00011 000 00011 0110011   006181B3
                                           add    r6    r3   0    r3   Rtype
add $r3 <- $r3, $r7                     0000000 00111 00011 000 00011 0110011   007181B3
                                           add    r7    r3   0    r3   Rtype
add $r3 <- $r3, $r8                     0000000 01000 00011 000 00011 0110011   008181B3
                                           add    r8    r3   0    r3   Rtype
add $r3 <- $r3, $r9                     0000000 01001 00011 000 00011 0110011   009181B3
                                           add    r9    r3   0    r3   Rtype
add $r3 <- $r3, $r10                    0000000 01010 00011 000 00011 0110011   00A181B3
                                           add   r10    r3   0    r3   Rtype
add $r3 <- $r3, $r11                    0000000 01011 00011 000 00011 0110011   00B181B3
                                           add   r11    r3   0    r3   Rtype
add $r3 <- $r3, $r12                    0000000 01100 00011 000 00011 0110011   00C181B3
                                           add   r12    r3   0    r3   Rtype
add $r3 <- $r3, $r13                    0000000 01101 00011 000 00011 0110011   00D181B3
                                           add   r13    r3   0    r3   Rtype
add $r3 <- $r3, $r14                    0000000 01110 00011 000 00011 0110011   00E181B3
                                           add   r14    r3   0    r3   Rtype
add $r3 <- $r3, $r15                    0000000 01111 00011 000 00011 0110011   00F181B3
                                           add   r15    r3   0    r3   Rtype
add $r3 <- $r3, $r16                    0000000 10000 00011 000 00011 0110011   010181B3
                                           add   r16    r3   0    r3   Rtype
add $r3 <- $r3, $r17                    0000000 10001 00011 000 00011 0110011   011181B3
                                           add   r17    r3   0    r3   Rtype
add $r3 <- $r3, $r18                    0000000 10010 00011 000 00011 0110011   012181B3
                                           add   r18    r3   0    r3   Rtype
add $r3 <- $r3, $r19                    0000000 10011 00011 000 00011 0110011   013181B3
                                           add   r18    r3   0    r3   Rtype
add $r3 <- $r3, $25                     0000000 10001 00011 000 00011 0110011   011181B3
                                           add   r17    r3   0    r3   Rtype
jump 00010100  // jumpt to the beq      000000010100 00000 000 00000 1100111    01400067
                                                imm     0 fun   imm   Itype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
add $r0 <- $r0, $r0                     0000000 00000 00000 000 00000 0110011   00000033
                                           add    r0    r0   0    r0   Rtype
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101
data                                   00000001 00000001 00000001 00000001     01010101