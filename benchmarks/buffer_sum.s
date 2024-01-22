        .set   STACK_PT, -544

        .macro WHERE_TO_READ
        auipc  a1, 0          # a1 = pc
        addi   a1, a1, 0x100
        .endm


main:
# begin - addi sp,sp,-544
        li     t3, -544
        add    sp,sp,t3       # Create stack
# end - addi sp,sp,-544
        sw     s0,540(sp)     # Save sp
# begin - addi sp,sp,544
        li     t3, 544
        add    sp,sp,t3       # Update sp
# end - addi sp,sp,544
        sw     zero,-20(s0)
        sw     zero,-24(s0)
        j      .L2
.L3:
        lw     a5,-24(s0)
        slli   a5,a5,2
        addi   a5,a5,-16
        add    a5,a5,s0
        lw     a5,-520(a5)
        lw     a4,-20(s0)
        add    a5,a4,a5
        sw     a5,-20(s0)
        lw     a5,-24(s0)
        addi   a5,a5,1
        sw     a5,-24(s0)
.L2:
        lw     a4,-24(s0)
        li     a5,127
        ble    a4,a5,.L3
        li     a5,0
        mv     a0,a5
        lw     s0,540(sp)
        addi   sp,sp,544
        jr     ra