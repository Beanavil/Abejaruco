; Beware that this is only RISC-V 32-bit code reference for an easier translation
main:
        addi    sp,sp,-544
        sw      s0,540(sp)
        addi    s0,sp,544
        sw      zero,-20(s0)
        sw      zero,-24(s0)
        j       .L2
.L3:
        lw      a5,-24(s0)
        slli    a5,a5,2
        addi    a5,a5,-16
        add     a5,a5,s0
        lw      a5,-520(a5)
        lw      a4,-20(s0)
        add     a5,a4,a5
        sw      a5,-20(s0)
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L2:
        lw      a4,-24(s0)
        li      a5,127
        ble     a4,a5,.L3
        li      a5,0
        mv      a0,a5
        lw      s0,540(sp)
        addi    sp,sp,544
        jr      ra