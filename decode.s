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


    # handle null string
    li a5, 4
    blt a5, a1, begin       # 길이 4면 rank만 들어오는거임.
    li a0, 0
    ret



begin:
    addi sp, sp, -128   # alloc stack

    # make empty a2, a3
    sw a2, 64(sp)       # *outp @feb0
    sw a3, 68(sp)       # outbytes @feb4
    sw ra, 72(sp)       # ra @feb8

    # handling ranking
    lw a3, 0(a0)            # load data
    call convert_endian     # bigendian @a5
    addi a1, a1, -4         # load한 걸 처리했으니 길이 -4
    sw a5, 84(sp)           # todo : decode시 reg놀이 할 때 대비.
    call store_rank

# a1: remain_bits, a2: padding->shift_remaining, a5: bigendian
    addi a0, a0, 4          # next input addr
    lw a3, 0(a0)
    call convert_endian     # a5에 bigendian 담겨있음.

    # read, handle padding_info
    srli a2, a5, 28         # a2 : padding_info
    slli a1, a1, 3          # 길이를 bit기준으로 바꿈.
    slli a5, a5, 4          # remove padding_info
    sub a1, a1, a2          # remain_bits = 길이-paddingbits
    addi a1, a1, -4         #               - info_bits
ebreak

    # a2, a3, a5 usable


    # restore values
    lw ra, 72(sp)       # ra to main func - sp를 바꾸기 전에 lw했어야지
    addi sp, sp, 128    # dealloc stack
    ebreak
    ret






convert_endian: # (in, out) = (a3, a5) / use a3, a4, a5
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
    sw a0, 76(sp)       # empty a0
    sw a1, 80(sp)       # empty a1

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
    andi a4, a5, 0xf    # rank 7
    sw a4, 28(sp)

    # put rank 8-15 in the memory
    # a0, a1, a2, a3, a4 usable
    addi a2, sp, 32     # a2: rank 8 들어갈 주소
    li a3, 0            # a3: int i = 0
    li a4, 0            # a4: int j = 0

loopi:
    li a4, 0            # j = 0

loopj:
    add a1, sp, a4      # a1 <- rank+j 주소 (j 자체를 4씩 키우자)
    lw a1, 0(a1)        # a1 <- rank[j] 값
    beq a3, a1, iupdate # i == rank[j]

    addi a4, a4, 4      # j++
    li a0, 32
    blt a4, a0, loopj   # a0 == 32

    sw a3, 0(a2)        # rank[n] = i;
    addi a2, a2, 4      # n++

iupdate:
    addi a3, a3, 1
    addi a0, zero, 16
    blt a3, a0, loopi

rank_done:
    lw a0, 76(sp)       # restore a0
    lw a1, 80(sp)       # restore a1
    ret
























