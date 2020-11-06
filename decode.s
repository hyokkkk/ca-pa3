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
#-------------------------------------------------------------------#


#from_inputbuf_to_token:
#        slli a0, a0, 1          # token <<1;
#        slli a5, a5, 1          # a5 <<=1;
#        addi a2, a2, -1         # bits_in_inputbuf --;
#
#        ret



#0x80000034
#sequential_read:
#        lui a4, 0x80000
#
#
#            slli a0, a0, 1      # token <<1
#            bltu a5, a4, dontadd
#            addi a0, a0, 1      # msb 1이면 token에 더해줌
#
#        dontadd:
#            slli a5, a5, 1
#            addi a2, a2, -1     # bits_in_inputbuf --;
#            addi a3, a3, -1     # loopcnt --;
#            ble a3, zero, exit  # a3 <= 0, ret
#            beq x0, x0, read
#
#        exit:
#            ret


load_data:
        lw a4, 92(sp)
        lw a3, 0(a4)            # a3에 data load받음
        li a2, 32               # bits_in_inputbuf = 32로 초기화
        addi a4, a4, 4          # 읽고 다음에 바로 읽을 수 있게 업데이트 해준다
        sw a4, 92(sp)           # inp addr 다시 저장

# convert_endian 하드코딩
        srli a4, a3, 24         # abxxxxxx -> 000000ab
        slli a5, a3, 24         # xxxxxxgh -> gh000000
        or a5, a4, a5           # gh0000ab
        srli a4, a3, 16         # abcdefgh -> 0000abcd
        andi a4, a4, 0xff       # 000000cd
        slli a4, a4, 8          # 0000cd00
        or a5, a5, a4           # gh00cdab
        srli a4, a3, 8          # abcdefgh -> 00abcdef
        slli a4, a4, 24         # ef000000
        srli a4, a4, 8          # 00ef0000
        or a5, a5, a4           # ghefcdab
        ret


convert_endian:                 # (in, out) = (a3, a5) / use a3, a4, a5
        srli a4, a3, 24         # abxxxxxx -> 000000ab
        slli a5, a3, 24         # xxxxxxgh -> gh000000
        or a5, a4, a5           # gh0000ab
        srli a4, a3, 16         # abcdefgh -> 0000abcd
        andi a4, a4, 0xff       # 000000cd
        slli a4, a4, 8          # 0000cd00
        or a5, a5, a4           # gh00cdab
        srli a4, a3, 8          # abcdefgh -> 00abcdef
        slli a4, a4, 24         # ef000000
        srli a4, a4, 8          # 00ef0000
        or a5, a5, a4           # ghefcdab
        ret


store_rank:
        sw a0, 92(sp)           # empty a0
        sw a1, 64(sp)           # empty a1

        srli a4, a5, 28         # rank 0
        sw a4, 0(sp)
        slli a4, a5, 4          # rank 1
        srli a4, a4, 28
        sw a4, 4(sp)
        slli a4, a5, 8          # rank 2
        srli a4, a4, 28
        sw a4, 8(sp)
        slli a4, a5, 12         # rank 3
        srli a4, a4, 28
        sw a4, 12(sp)
        slli a4, a5, 16         # rank 4
        srli a4, a4, 28
        sw a4, 16(sp)
        slli a4, a5, 20         # rank 5
        srli a4, a4, 28
        sw a4, 20(sp)
        slli a4, a5, 24         # rank 6
        srli a4, a4, 28
        sw a4, 24(sp)
        andi a4, a5, 0xf        # rank 7
        sw a4, 28(sp)

        # put rank 8-15 in the memory
        # a0, a1, a2, a3, a4 usable
        addi a2, sp, 32             # a2: rank 8 들어갈 주소
        li a3, 0                    # a3: int i = 0
        li a4, 0                    # a4: int j = 0

        loopi:
                li a4, 0            # j = 0
        loopj:
                add a1, sp, a4      # a1 <- rank+j 주소 (j 자체를 4씩 키우자)
                lw a1, 0(a1)        # a1 <- rank[j] 값
                beq a3, a1, iupdate # i == rank[j]

                addi a4, a4, 4      # j++
                li a0, 32
                bltu a4, a0, loopj  # a0 == 32

                sw a3, 0(a2)        # rank[n] = i;
                addi a2, a2, 4      # n++
        iupdate:
                addi a3, a3, 1
                addi a0, zero, 16
                bltu a3, a0, loopi
        rank_done:
                lw a0, 92(sp)       # restore a0
                lw a1, 64(sp)       # restore a1
        ret
#--------------------------------------------------------------#




decode:
# special handlings
#   1. inbytes == 0 : return 0
#   2. length of output(ret) > outbytes : return -1


    # handle null string
        li a5, 4
        bltu a5, a1, begin       # 길이 4면 rank만 들어오는거임.
        li a0, 0

        ret


begin:
        addi sp, sp, -128   # alloc stack

        # make empty a2, a3
        sw a2, 96(sp)           # *outp @feb0
        sw a3, 68(sp)           # outbytes @feb4
        sw ra, 72(sp)           # ra @feb8

        # handling ranking
        lw a3, 0(a0)            # load rank
        call convert_endian     # bigendian @a5
        call store_rank

# a0: inp addr, a1: bits_should_be_read, a5: bigendian
        addi a0, a0, 4          # next input addr
        lw a3, 0(a0)            # load padding_info + codes
        addi a0, a0, 4          # 다음에 바로 읽도록 update해놓는다.
        sw a0, 92(sp)           # inp addr는 쓰고 바로 담자.

        call convert_endian     # a5에 bigendian 담겨있음.
        li a4, 32               # empty_bits_in_outbuf = 32로 초기화해놔야함.
        sw a4, 84(sp)           # 메모리에 저장해놓고 나중에 사용.

        # read, handle padding_info
        srli a2, a5, 28         # a2 : padding_info
        slli a1, a1, 3          # 길이를 bit기준으로 바꿈.
        slli a5, a5, 4          # remove padding_info
        sub a1, a1, a2          # bits_should_be_read = 전체길이 - rank32bit
        addi a1, a1, -36         #               - info_bits - padding_bits
        li a2, 28




############## 여기까지 패딩 가공 끝###################

# a0: token, a1: total_to_read, a2: waiting, a3: loopcnt, a4: temporary, a5: bigendian
# 원래 function으로 만들어놨던 sequential_read, from_inputbuf_to_token 를 그냥 하드코딩으로 함. 불필요한 instruction 줄이기 위해



decoding_loop:
    # 길이 안 맞는것들 handle
        addi a0, zero, 0            # token init : 0
        lui a4, 0x80000

    L0xxxx:
        bgeu a5, a4, L1xxxx         # a5 >= 0x80000000

        #from_inputbuf_to_token
        slli a0, a0, 1          # token <<1;
        slli a5, a5, 1          # a5 <<=1;
        addi a2, a2, -1         # bits_in_inputbuf --;

        li a3, 2
        bltu a2, a3, L0buf0bit
        addi a1, a1, -3             # bits_should_be_read -3

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd0
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd0:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd1
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd1:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;

        jal match_with_rank

        L0buf0bit:
                bne a2, zero, L0buf1bit
                call load_data
                lui a4, 0x80000
                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd02
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd02:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd2
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd2:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                addi a1, a1, -3
                jal match_with_rank

        L0buf1bit:

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd3
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd3:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                call load_data
                lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd4
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd4:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                addi a1, a1, -3
                jal match_with_rank

    L1xxxx:
        lui a4, 0x80000
        #from_inputbuf_to_token
        slli a0, a0, 1          # token <<1;
        slli a5, a5, 1          # a5 <<=1;
        addi a2, a2, -1         # bits_in_inputbuf --;

        addi a0, a0, 1

        bne a2, zero, L10xxx
        call load_data
        lui a4, 0x80000

        L10xxx:
            bgeu a5, a4, L11xxx

            #from_inputbuf_to_token
            slli a0, a0, 1          # token <<1;
            slli a5, a5, 1          # a5 <<=1;
            addi a2, a2, -1         # bits_in_inputbuf --;

            li a3, 2
            bltu a2, a3, L10buf0bit

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd5
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd5:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd6
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd6:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


            addi a1, a1, -4
            jal match_with_rank

            L10buf0bit:
                    bne a2, zero, L10buf1bit
                    call load_data
                    lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd8
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd8:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd9
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd9:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    addi a1, a1, -4
                    jal match_with_rank

            L10buf1bit:

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd10
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd10:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    call load_data
                    lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd11
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd11:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    addi a1, a1, -4
                    jal match_with_rank

        L11xxx:
        #from_inputbuf_to_token
        slli a0, a0, 1          # token <<1;
        slli a5, a5, 1          # a5 <<=1;
        addi a2, a2, -1         # bits_in_inputbuf --;

            addi a0, a0, 1

            li a3, 3
            bltu a2, a3, L11buf2bit

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd12
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd12:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd13
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd13:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd14
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd14:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
            addi a1, a1, -5
            jal match_with_rank

            L11buf2bit:
                    li a3, 2
                    bne a2, a3, L11buf0bit

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd15
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd15:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd16
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd16:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                    call load_data
                    lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd18
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd18:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    addi a1, a1, -5
                    jal match_with_rank

            L11buf0bit:
                    bne a2, zero, L11buf1bit
                    call load_data
                    lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd19
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd19:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd20
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd20:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd21
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd21:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    addi a1, a1, -5
                    jal match_with_rank

            L11buf1bit:

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd22
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd22:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    call load_data
                    lui a4, 0x80000

                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd23
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd23:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;


                                    slli a0, a0, 1      # token <<1
                                    bltu a5, a4, dontadd24
                                    addi a0, a0, 1      # msb 1이면 token에 더해줌
                                dontadd24:
                                    slli a5, a5, 1
                                    addi a2, a2, -1     # bits_in_inputbuf --;
                    addi a1, a1, -5
                    jal match_with_rank
#-----------------------------------------------------#






match_with_rank:
        # a0: token에 들어있는 값으로 매칭시킨다.
        # a3 : outputreg, a4 : 맘껏쓰시오
        lw a3, 88(sp)   # outputreg가 저장돼있는 주소. 처음엔 0이다.

        rank0:
            bne a0, zero, rank1
            lw a4, 0(sp)            # rank0의 주소에 가서 로드
            slli a3, a3, 4          # 쓰기 전에 shift한다. 쓰고 shift하면 마지막에 촛됨
            or a3, a3, a4
            jal check_outreg_full
        rank1:
            li a4, 1
            bne a0, a4, rank2
            lw a4, 4(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank2:
            li a4, 2
            bne a0, a4, rank3
            lw a4, 8(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank3:
            li a4, 3
            bne a0, a4, rank4
            lw a4, 12(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank4:
            li a4, 8
            bne a0, a4, rank5
            lw a4, 16(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank5:
            li a4, 9
            bne a0, a4, rank6
            lw a4, 20(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank6:
            li a4, 10
            bne a0, a4, rank7
            lw a4, 24(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank7:
            li a4, 11
            bne a0, a4, rank8
            lw a4, 28(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank8:
            li a4, 24
            bne a0, a4, rank9
            lw a4, 32(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank9:
            li a4, 25
            bne a0, a4, rank10
            lw a4, 36(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank10:
            li a4, 26
            bne a0, a4, rank11
            lw a4, 40(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank11:
            li a4, 27
            bne a0, a4, rank12
            lw a4, 44(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank12:
            li a4, 28
            bne a0, a4, rank13
            lw a4, 48(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank13:
            li a4, 29
            bne a0, a4, rank14
            lw a4, 52(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank14:
            li a4, 30
            bne a0, a4, rank15
            lw a4, 56(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full
        rank15:
            li a4, 31
            bne a0, a4, err
            lw a4, 60(sp)
            slli a3, a3, 4
            or a3, a3, a4
            jal check_outreg_full



check_outreg_full:
# 4bit token하나가 더 추가됐으니 outlen도 더하고, empty_bits_in_outbuf 도 -4하자.
        lw a0, 100(sp)              # outlen load
        addi a0, a0, 1              # outlen ++

# 혹시 outlen 긴 거를 무시하고 계속 메모리에 써서?
        lw a4, 68(sp)               # outbytes 다시 로드
        slli a4, a4, 1              # outlen이 2배 돼있는 상황이니 outbyte를 2배로 해서 비교
        bltu a4, a0, check_overflow # outbytes < outlen -> -1 return하러 가자

no_overflow:
        lw a4, 84(sp)               # empty_bits_in_outbuf. 시작할 때 32로 초기화 해야함
        addi a4, a4, -4


noMoreData:
        bne a1, zero, full_outBuf
        srli a0, a0, 1              # outlen/2
        call convert_endian         # 어짜피 끝이니 저장할 것 없음.

        andi a2, a0, 0x3            # outlen의 last 1byte 추출

        beq a2, zero, print         # 마지막 1byte가 0이면 걍 인쇄
        addi a4, zero, 1            # a4 : 1
        bne a2, a4, not_mod1        # 길이가 1 남으면 끝 3byte 제거
        srli a5, a5, 24
    not_mod1:
        addi a4, zero, 2            # a4 : 2
        bne a2, a4, not_mod2
        srli a5, a5, 16
    not_mod2:
        addi a4, zero, 3
        bne a2, a4, print
        srli a5, a5, 8
    print:
        lw a3, 96(sp)               # outp addr 읽어옴(이 자리에 바로 쓰면 됨)
        sw a5, 0(a3)
        beq zero, zero, Exit



#0x80000438
full_outBuf:
        bne a4, x0, inpBuf_empty    # empty_bits_in_outbuf ==0 이면 밑에 수행
        sw a5, 80(sp)               # buf에 남아있을 수도 있으니 일단 save
        call convert_endian         # a5에 결과가 담김.

        lw a3, 96(sp)               # outp addr 읽어옴
        sw a5, 0(a3)                # 그 주소에 저장
        addi a3, a3, 4              # outp addr update
        sw a3, 96(sp)               # 다시 그 자리에 저장

        li a4, 32                   # 비웠으니 empty_bits_in_outbuf = 32로 다시 초기화
        li a3, 0                    # outbuf도 0으로 초기화
        sw a4, 84(sp)               # empty_bits_in_outbuf도 저장해놓음.

        lw a5, 80(sp)               # 저장해놨던 buf 다시 a5에 넣음.


inpBuf_empty:
        bne a2, zero, lastBuf       # bits_in_inputbuf == 0이면 밑에 수행
        sw a3, 88(sp)               # 추가함.
        sw a4, 84(sp)

        call load_data

        lw a3, 88(sp)
        lw a4, 84(sp)


lastBuf:
        bltu a2, a1, decodeAgain    # 마지막 loop면 waiting > total일 수도 있음.
        mv a2, a1                   # bits_in_inputbuf = bits_should_be_read


decodeAgain:
        sw a3, 88(sp)               # outbuf 다 안 찬 상태로 다시 loop돌면 이 값 없어짐.
        sw a4, 84(sp)               # empty_bits_in_outbuf도 다시 저장.
        sw a0, 100(sp)              # outlen도 저장
        jal decoding_loop


Exit:
        # restore values
        lw ra, 72(sp)               # ra to main func - sp를 바꾸기 전에 lw했어야지
        lw a4, 68(sp)               # outbytes 다시 로드
        addi sp, sp, 128            # dealloc stack

check_overflow:
        bgeu a4, a0, return         # outbytes >= outlen -> 걍 return
        addi a0, zero, -1           # outbytes < outlen -> -1 return

return:
        ret

err:
        lui a0, 0x01234             #err check
        jal Exit

