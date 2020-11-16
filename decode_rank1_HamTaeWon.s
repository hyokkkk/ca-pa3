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
#  a0 = inp, a1 = inbytes, a2 = outp, a3 = outbytes
#---------------------------------------------------------------------
	.globl	decode
decode:

	#  special case : return 0 if inbytes == 0
	bne a1, zero, nonzero_inbytes
	addi a0, zero, 0
	ret

nonzero_inbytes:
	#-----------------------------------------------------------------
	#  push stack
	#-----------------------------------------------------------------
	addi sp, sp, -92
	sw ra, 88(sp)
	sw a3, 84(sp) # outbytes
	sw a3, 80(sp) # outbytes left
	sw a2, 76(sp) # outp
	sw a1, 72(sp) # inbytes, also used for 'bitsleft'
	sw a0, 68(sp) # inp
    # sp + 64 used for 'loadoffset'
	# sp + 60 ~ sp + 0 used for 'rank table'

	#-----------------------------------------------------------------
	#  read rank table & end info
	#  save at sp + 60 ~ sp + 0
	#-----------------------------------------------------------------

#####  1. fill in first half of rank table (from largest) ------------
	#     first word of inp has rank 0~7 in order
	addi a5, a0, 0   # a5 is now inp
	lw a0, 0(a5)
	jal ra, toggle_endian

	addi a4, sp, 28  # sp + 4*7
Loop_rank_1:
	andi a1, a0, 0xf # read last 4 bits
	sw a1, 0(a4)
	srli a0, a0, 4   # next 4 bits
	addi a4, a4, -4
	bge a4, sp, Loop_rank_1

#####  2. fill in rest of rank table (from largest) ------------------
	#     find what number isn't already in and add them in order
	addi a0, zero, 15      # number to find
	addi a4, sp, 60        # entry to fill
Loop_rank_2_out:
	addi a3, sp, 28		   # entry to check (in first half)
Loop_rank_2_in:
	lw a2, 0(a3)
	beq a2, a0, Exit_rank_2_in # exit inner loop if number is found
	addi a3, a3, -4
	bge a3, sp, Loop_rank_2_in
	sw a0, 0(a4)           # store if number is not found
	addi a4, a4, -4
Exit_rank_2_in:
	addi a0, a0, -1
	bge a0, zero, Loop_rank_2_out

#####  3. shift all codes to bits 28 ~ 31 (for later convenience)
	addi a4, sp, 60
Loop_rank_3:
	lw a0, 0(a4)
	slli a0, a0, 28
	sw a0, 0(a4)
	addi a4, a4, -4
	bge a4, sp, Loop_rank_3
	
#####  4. read end info ----------------------------------------------
	addi a5, a5, 4
	sw a5, 68(sp)    # save new inp
	lw a0, 0(a5)	 # a0 = *(inp + 4). end info is saved at bits 4 ~ 7
	srli a2, a0, 4
	andi a2, a2, 0xf # a2 = end info

	#-----------------------------------------------------------------
	#  DECODE!
	#  a0 - read various values from stack,
	#     - read inp every time input stream needs refilling
	#  a2 - contains 'outputstream'
    #  a3 - contains 'inputstream' (upper 32 bits)
    #  a4 - contains 'inputstream' (lower 32 bits)
    #  a5 - contains 'loadoffset'
	#-----------------------------------------------------------------

#####  1. initialize -------------------------------------------------
	jal ra, toggle_endian # a0 currently has *(inp + 4) in big endian
	slli a3, a0, 4   # upper inputstream initialized
    addi a4, zero, 0 # lower inputstream initialized
	addi a5, zero, 4 # loadoffset initializeed

	#     determine number of bits left to read
	#     'bitsleft' = 8*inbytes - 32(rank table bits) - 4(end info bits) - 28(initially read bits) - end info
	lw a0, 72(sp)    # a0 = inbytes
	slli a0, a0, 3
	addi a0, a0, -64
	sub a0, a0, a2   # a0 = 8*inbytes - 64 - end info
	sw a0, 72(sp)    # store bitsleft

	#     check if all inputs are loaded
	bge zero, a0, Exit_decode8

#####  2. decode 8 codes ---------------------------------------------
Loop_decode8:
	#     decode 4 codes (1)
	jal ra, decode4 # 'decode4' subroutine
	bge zero, a5, decode8_2 # skip refill if loadoffset <= 0

	#     refill inputstream

	#     get next input
    lw a0, 68(sp)
	addi a0, a0, 4 # current inp + 4
	sw a0, 68(sp)  # update inp
	lw a0, 0(a0)
    jal ra, toggle_endian

	#     append to inputstream
	sll a4, a0, a5   # update lower 32 bits of inputstream
	sub a1, zero, a5 # (-loadoffset)
	srl a0, a0, a1	 # next input >> (32 - decodedbits)
    or a3, a3, a0    # update upper 32 bits of inputstream
	addi a5, a5, -32 # loadoffset -= word size

	#     update bitsleft
	lw a0, 72(sp)    # bitsleft
	addi a0, a0, -32 # bitsleft -= word size
	sw a0, 72(sp)
	blt zero, a0, decode8_2 # still more bits to read
	#     jump to middle of final loop (read explanation of 'DECODE final few bits')
	sub a5, a0, a5
	addi a5, a5, 32
	sw a5, 64(sp)
	addi a0, zero, 1 # count
	jal zero, Loop_decode8_final_in

decode8_2:
	#     decode 4 codes (2)
	jal ra, decode4 # 'decode4' subroutine

#####  3. store outputstream to memory -------------------------------
    lw a0, 76(sp) # current outp
    sw a2, 0(a0)
    addi a0, a0, 4
    sw a0, 76(sp)

#####  4. check outbytes left ----------------------------------------
    lw a0, 80(sp)   # outbytes left
    addi a0, a0, -4 # 8 codes decoded = 4 bytes
	sw a0, 80(sp)
	blt zero, a0, enough_space
	#     special case: not enough space to output, return -1
	addi a0, zero, -1
	lw ra, 88(sp)
	addi sp, sp, 92
	ret

enough_space:
	bge zero, a5, Loop_decode8 # skip refill if loadoffset <= 0

	#     refill inputstream -----------------------------------------

	#     get next input
    lw a0, 68(sp)
	addi a0, a0, 4 # current inp + 4
	sw a0, 68(sp)  # update inp
	lw a0, 0(a0)
    jal ra, toggle_endian

	#     append to inputstream
	sll a4, a0, a5   # update lower 32 bits of inputstream
	sub a1, zero, a5 # (-loadoffset)
	srl a0, a0, a1	 # next input >> (32 - decodedbits)
    or a3, a3, a0    # update upper 32 bits of inputstream
	addi a5, a5, -32 # loadoffset -= word size

		#     update bitsleft
	lw a0, 72(sp)    # bitsleft
	addi a0, a0, -32 # bitsleft -= word size
	sw a0, 72(sp)
	blt zero, a0, Loop_decode8 # still more bits to read

Exit_decode8:
	#--------------------------------------------------------------
	#  DECODE final few bits
	#  right now, bits actually left = bitsleft(in a0) - loadoffset(in a5) + 32
	#  do the same thing, but while checking bits actually left
	#--------------------------------------------------------------
#####  1. initialize. current state of stack and registers are as follows:
	#     a0 = (bits read in the final refill) - 32
	#     a3, a4 = inputstream
	#     a5 = loadoffset

	sub a5, a0, a5
	addi a5, a5, 32 # a5 = bits actually left
	sw a5, 64(sp)   # save bits left in 64(sp)

#####  2. decode 8 codes
Loop_decode8_final_out:
    addi a0, zero, 3 # count

Loop_decode8_final_in:
#####  2-1. decode (0th, 2nd, 4th, 6th position)
    srli a1, a3, 27 # first 5 bits of inputstream
    addi a1, a1, -16
    blt a1, zero, Case_3bits_final_1
    addi a1, a1, -8
    blt a1, zero, Case_4bits_final_1

Case_5bits_final_1:
	slli a1, a1, 2
    add a1, a1, sp
    lw a1, 32(a1)
	#  update inputstream
	slli a3, a3, 5
	srli a5, a4, 27 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 5  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -5
	sw a5, 64(sp)
    jal zero, Case_end_final_1

Case_4bits_final_1:
    andi a1, a1, -2
    slli a1, a1, 1
    add a1, a1, sp
    lw a1, 32(a1)
	#  update inputstream
	slli a3, a3, 4
	srli a5, a4, 28 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 4  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -4
	sw a5, 64(sp)
    jal zero, Case_end_final_1

Case_3bits_final_1:
    andi a1, a1, -4
    add a1, a1, sp
    lw a1, 16(a1)
	#  update inputstream
	slli a3, a3, 3
	srli a5, a4, 29 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 3  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -3
	sw a5, 64(sp)

Case_end_final_1:
	#  store 1 code in outputstream
    srli a2, a2, 8
    or a2, a2, a1
	#  check if bits left were all used
	bge zero, a5, Exit_decode8_final_out

#####  2-2. decode (1st, 3rd, 5th, 7th position)
    srli a1, a3, 27 # first 5 bits of inputstream
    addi a1, a1, -16
    blt a1, zero, Case_3bits_final_2
    addi a1, a1, -8
    blt a1, zero, Case_4bits_final_2

Case_5bits_final_2:
	slli a1, a1, 2
    add a1, a1, sp
    lw a1, 32(a1)
	#  update inputstream
	slli a3, a3, 5
	srli a5, a4, 27 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 5  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -5
	sw a5, 64(sp)
    jal zero, Case_end_final_2

Case_4bits_final_2:
    andi a1, a1, -2
    slli a1, a1, 1
    add a1, a1, sp
    lw a1, 32(a1)
	#  update inputstream
	slli a3, a3, 4
	srli a5, a4, 28 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 4  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -4
	sw a5, 64(sp)
    jal zero, Case_end_final_2

Case_3bits_final_2:
    andi a1, a1, -4
    add a1, a1, sp
    lw a1, 16(a1)
	#  update inputstream
	slli a3, a3, 3
	srli a5, a4, 29 # a5 = lower 32 bits of inputstream >> (32 - 5)
	or a3, a3, a5   # update upper 32 bits of inputstream
	slli a4, a4, 3  # update lower 32 bits of inputstream
    #  update bits left
	lw a5, 64(sp)
	addi a5, a5, -3
	sw a5, 64(sp)

Case_end_final_2:
	#  store 1 code in outputstream
    srli a1, a1, 4
    or a2, a2, a1
	#  check if bits left were all used
	bge zero, a5, Exit_decode8_final_out
	addi a0, a0, -1
    bge a0, zero, Loop_decode8_final_in

#####  3. store outputstream to memory
    lw a0, 76(sp) # current outp
    sw a2, 0(a0)
    addi a0, a0, 4
    sw a0, 76(sp)

    #  check outbytes left
    lw a0, 80(sp)   # outbytes left
    addi a0, a0, -4 # 8 codes decoded = 4 bytes
	sw a0, 80(sp)
	blt zero, a0, Loop_decode8_final_out
	#  special case: not enough space to output, return -1
	addi a0, zero, -1
	lw ra, 88(sp)
	addi sp, sp, 92
	ret

Exit_decode8_final_out:
	#  right now a0 = one of [3, 2, 1, 0]
	#  inputstream is not used again

	#  get actual outbytes left
	lw a4, 80(sp)   # outbytes left
	add a4, a4, a0  # becomes outbytes+3 ~ outbytes+0
	addi a4, a4, -4 # becomes outbytes-1 ~ outbytes-4

	bge a4, zero, enough_space_2
	# special case: not enough space to output, return -1
	addi a0, zero, -1
	lw ra, 88(sp)
	addi sp, sp, 92
	ret
enough_space_2:
	
	#  store outputstream to memory
	slli a1, a0, 3  # a1 = 8*count
	srl a2, a2, a1 # modify outputstream so first bits read come to bits 0 ~ 3
    lw a0, 76(sp)   # current outp
    sw a2, 0(a0)

	#------------------------------------------------
	#  pop stack
	#  make return value
	#------------------------------------------------
	lw a0, 84(sp)  # outbytes
	sub a0, a0, a4 # actual output bytes

	lw ra, 88(sp)
	addi sp, sp, 92
	ret

#---------------------------------------------------------------------
#  subprocedure to decode 4 bits
#  this is not a separate function; it shares stack and registers with 'decode'
#  a0 - used to count in inner loop
#  a2 - 'outputstream'
#  a3 - 'inputstream' (upper 32 bits)
#  a4 - 'inputstream' (lower 32 bits)
#  a5 - contains 'decodedbits'
#---------------------------------------------------------------------
decode4:
#####  1. initialization
	sw a5, 64(sp)    # store (a5 is loadoffset before this)
	addi a5, zero, 0 # from now, a5 = decodedbits
	addi a0, zero, 2 # count

Loop_decode4:
#####  2. decode 1 code(0th & 2nd position)
    srli a1, a3, 27 # first 5 bits of inputstream
    addi a1, a1, -16
    blt a1, zero, Case_3bits_1 # if the bits were 00000 ~ 01111, only the first 3 bits are code
    addi a1, a1, -8
    blt a1, zero, Case_4bits_1 # if the bits were 10000 ~ 10111, only the first 4 bits are code

Case_5bits_1: # a1 = 11000 ~ 11111 (code = a1)
    addi a5, a5, 5 # 5 newly decoded bits
    slli a3, a3, 5 # discard first 5 bits of inputstream
    slli a1, a1, 2
    add a1, a1, sp # a1 = sp + 4*(code - 24)
    lw a1, 32(a1)  # a1 = *(sp + 4*(code - 16))
    jal zero, Case_end_1

Case_4bits_1: # a1 = 10000 ~ 10111 (code = a1 >> 1)
    addi a5, a5, 4  # 4 newly decoded bits
    slli a3, a3, 4  # discard first 4 bits of inputstream
    andi a1, a1, -2 # a1 = 2*code - 24
    slli a1, a1, 1  # a1 = 4*(code - 12)
    add a1, a1, sp
    lw a1, 32(a1)   # a1 = *(sp + 4*(code - 4))
    jal zero, Case_end_1

Case_3bits_1: # a1 = 00000 ~ 01111 (code = a1 >> 2)
    addi a5, a5, 3  # 3 newly decoded bits
    slli a3, a3, 3  # discard first 3 bits of inputstream
    andi a1, a1, -4 # a1 = 4*code - 16
    add a1, a1, sp
    lw a1, 16(a1)   # a1 = *(sp + 4*code)

Case_end_1:
	#     store code in outputstream
	#     the code in a1 is in bits 28~31
    srli a2, a2, 8
    or a2, a2, a1
	
#####  3. decode 1 code(1st & 3rd position)
    srli a1, a3, 27 # first 5 bits of inputstream
    addi a1, a1, -16
    blt a1, zero, Case_3bits_2 # if the bits were 00000 ~ 01111, only the first 3 bits are code
    addi a1, a1, -8
    blt a1, zero, Case_4bits_2 # if the bits were 10000 ~ 10111, only the first 4 bits are code

Case_5bits_2: # a1 = 11000 ~ 11111 (code = a1)
    addi a5, a5, 5 # 5 newly decoded bits
    slli a3, a3, 5 # discard first 5 bits of inputstream
    slli a1, a1, 2
    add a1, a1, sp # a1 = sp + 4*(code - 24)
    lw a1, 32(a1)  # a1 = *(sp + 4*(code - 16))
    jal zero, Case_end_2

Case_4bits_2: # a1 = 10000 ~ 10111 (code = a1 >> 1)
    addi a5, a5, 4  # 4 newly decoded bits
    slli a3, a3, 4  # discard first 4 bits of inputstream
    andi a1, a1, -2 # a1 = 2*code - 24
    slli a1, a1, 1  # a1 = 4*(code - 12)
    add a1, a1, sp
    lw a1, 32(a1)   # a1 = *(sp + 4*(code - 4))
    jal zero, Case_end_2

Case_3bits_2: # a1 = 00000 ~ 01111 (code = a1 >> 2)
    addi a5, a5, 3  # 3 newly decoded bits
    slli a3, a3, 3  # discard first 3 bits of inputstream
    andi a1, a1, -4 # a1 = 4*code - 16
    add a1, a1, sp
    lw a1, 16(a1)   # a1 = *(sp + 4*code)

Case_end_2:
	#     store code in outputstream
	#     the code in a1 is in bits 28~31
    srli a1, a1, 4
    or a2, a2, a1

	addi a0, a0, -1
    bne a0, zero, Loop_decode4

#####  4. update inputstream
	sub a0, zero, a5 # (-decodedbits)
	srl a0, a4, a0 # lower 32 bits of inputstream >> (32 - decodedbits)
	or a3, a3, a0  # update upper 32 bits of inputstream
	sll a4, a4, a5 # update lower 32 bits of inputstream

#####  5. update loadoffset
	lw a0, 64(sp)  # former loadoffset
	add a5, a0, a5 # new loadoffset
	ret


#---------------------------------------------------------------------
#  int toggle_endian(int n)
#  toggles between little and big endian
#  only modifies a0 and a1 registers
#---------------------------------------------------------------------
toggle_endian:
	addi sp, sp, -4
	sw a2, 0(sp)
	#  1st byte
	andi a2, a0, 0xff
	slli a2, a2, 8
	srli a0, a0, 8
	#  2nd byte
	andi a1, a0, 0xff
	or a2, a2, a1
	slli a2, a2, 8
	srli a0, a0, 8
	#  3rd byte
	andi a1, a0, 0xff
	or a2, a2, a1
	slli a2, a2, 8
	srli a0, a0, 8
	#  4th byte
	andi a1, a0, 0xff
	or a2, a2, a1

	#  return
	addi a0, a2, 0
	lw a2, 0(sp)
	addi sp, sp, 4
	ret
