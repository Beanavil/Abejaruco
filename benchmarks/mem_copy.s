main:
        addi    sp,sp,-1056
        sw      s0,1052(sp)
        addi    s0,sp,1056
        sw      zero,-20(s0)
        j       .L2
.L3:
        lw      a5,-20(s0)
        slli    a5,a5,2
        addi    a5,a5,-16
        add     a5,a5,s0
        li      a4,5
        sw      a4,-520(a5)
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        li      a5,127
        ble     a4,a5,.L3
        sw      zero,-24(s0)
        j       .L4
.L5:
        lw      a5,-24(s0)
        slli    a5,a5,2
        addi    a5,a5,-16
        add     a5,a5,s0
        lw      a4,-520(a5)
        lw      a5,-24(s0)
        slli    a5,a5,2
        addi    a5,a5,-16
        add     a5,a5,s0
        sw      a4,-1032(a5)
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L4:
        lw      a4,-24(s0)
        li      a5,127
        ble     a4,a5,.L5
        li      a5,0
        mv      a0,a5
        lw      s0,1052(sp)
        addi    sp,sp,1056
        jr      ra