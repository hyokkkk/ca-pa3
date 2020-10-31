#----------------------------------------------------------------
#
#  4190.308 Computer Architecture (Fall 2020)
#
#  Project #3: RISC-V Assembly Programming
#
#  October 26, 2020
#
#  Injae Kang (abcinje@snu.ac.kr)
#  Sunmin Jeong (sunnyday0208@snu.ac.kr)
#  Systems Software & Architecture Laboratory
#  Dept. of Computer Science and Engineering
#  Seoul National University
#
#----------------------------------------------------------------


	.text
	.align	2

#---------------------------------------------------------------------
#  int decode(const char *inp, int inbytes, char *outp, int outbytes)
#---------------------------------------------------------------------
	.globl	decode
decode:
# special handlings
#   1. inbytes == 0 : return 0
#   2. length of output(ret) > outbytes : return -1

# TODO : caller saved reg만 사용하니까 save할 필요 없는거지? -> 내가 callee saved를 안 쓰면 되지.
# TODO : stack pointer 조절해야하나? 모르겟음. 일단 다른거부터 먼저 하고 나중에 생각하자.

    # handle null string
    bne a1, zero, begin
    li a0, 0

    ret

# start
begin:
    addi sp, sp, -128   # alloc stack
    # make empty a2, a3
    sw a2, 64(sp)     # *outp @feb0
    sw a3, 68(sp)     # outbytes @feb4
    sw ra, 72(sp)     # ra @feb8
    # load data from memory
    lw a3, 0(a0)
    call convert_endian 
    # store rank at stack
    call store_rank

    # restore values
    lw ra, 72(sp)       # ra to main func - sp를 바꾸기 전에 lw했어야지
    addi sp, sp, 128    # dealloc stack
    ret

convert_endian: # (in, out) = (a3, a5) / use 3regs
    srli a4, a3, 24     # abxxxxxx -> 000000ab
    slli a5, a3, 24     # xxxxxxgh -> gh000000
    or a5, a4, a5       # gh0000ab
    srli a4, a3, 16     # abcdefgh -> 0000abcd
    andi a4, a4, 0xff   # 000000cd
    slli a4, a4, 8      # 0000cd00
    or a5, a5, a4       # gh00cdab
    srli a4, a3, 8      # abcdefgh -> 00abcdef
    slli a4, a4, 24     # ef000000
    srli a4, a4, 8      # 00ef0000
    or a5, a5, a4       # ghefcdab
    ret

store_rank:
# TODO : 나중에 reg여유있으면 상위rank는 reg에 넣어놓기
    srli a4, a5, 28     # rank 0
    sw a4, 0(sp)
    slli a4, a5, 4      # rank 1
    srli a4, a4, 28
    sw a4, 4(sp)
    slli a4, a5, 8      # rank 2
    srli a4, a4, 28
    sw a4, 8(sp)
    slli a4, a5, 12     # rank 3
    srli a4, a4, 28
    sw a4, 12(sp)
    slli a4, a5, 16     # rank 4
    srli a4, a4, 28
    sw a4, 16(sp)
    slli a4, a5, 20     # rank 5
    srli a4, a4, 28
    sw a4, 20(sp)
    slli a4, a5, 24     # rank 6
    srli a4, a4, 28
    sw a4, 24(sp)
    andi a4, a5, 0xf   # rank 7
    sw a4, 28(sp)
    ebreak
