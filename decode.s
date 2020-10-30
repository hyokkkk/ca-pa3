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
    # make empty a2, a3
    sw a2, 0(sp)    # *outp
    sw a3, 4(sp)    # outbytes

    # load data from memory
    lw a3, 0(a0)
    call convert_endian


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
    ebreak


    ret     #length of the output
