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

# length of output > outbytes : return -1

    # inbytes == 0 : return 0
    bne a1, zero, begin
    li a0, 0
    ebreak
    ret 

begin:


    ret     #length of the output
