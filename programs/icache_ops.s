# Instruction                   Binary                                  Hex         Addr

nop                             000000000000  00000 000 00000 0000000   00000000    00000000
nop                             000000000000  00000 000 00000 0000000   00000000    00000004
li $r1 <- 2                     000000000010  00000 001 00001 0000011   00201083    00000008
                                           2     0   0     r1   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011   00101103    0000000C
                                           1     0   0     r2   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011   00101103    0000000C
                                           1     0   0     r2   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011   00101103    0000000C
                                           1     0   0     r2   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011   00101103    0000000C
                                           1     0   0     r2   Itype
li $r2 <- 1                     000000000001  00000 001 00010 0000011   00101103    0000000C
                                           1     0   0     r2   Itype
stw 0(r2) <- r1                 0000000 00001 00010 010 00000 0100011   00112023    00000010
                                      0     1     2         0   Stype
nop                             000000000000  00000 000 00000 0000000   00000000
nop                             000000000000  00000 000 00000 0000000   00000000
nop                             000000000000  00000 000 00000 0000000   00000000
nop                             000000000000  00000 000 00000 0000000   00000000
