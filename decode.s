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
    ebreak
    ret

# start 
begin:
    # load data from memory
#s;dl


    ret     #length of the output
