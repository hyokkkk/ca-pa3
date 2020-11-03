#include <stdio.h>


//test0
    unsigned int bigendian[] = {0xb43088c0, 0x89659708, 0x891e168b, 0xa1d10383, 0x8d69400};
    int wating_for_decoding = 28;
    int totalBitsToRead = (0x18<<3)-32-4-7;


//test1
//   unsigned int bigendian[3] = {0x8233f9a0, 0x8921f915, 0x636c0000};
//   int wating_for_decoding = 28; //padding 다 없앤 후
//   int totalBitsToRead = 74;

//test2
// unsigned int bigendian[] = {0x8a162130, 0x38303432, 0x38984509, 0x247d3004,
//                            0x9b4c6cc0, 0xf1672989, 0x2041499a, 0x162131d1,
//                            0x83b3a4c5, 0x09057c00};
//
//int wating_for_decoding = 28;
//int totalBitsToRead = 306;


//test3
//   unsigned int bigendian[3] = {0x68820000};
//   int wating_for_decoding = 28;
//  int totalBitsToRead = 18;
    int i = 0;
    int a5 = 0;
    int outregEmpty=32;
    int outlen=0;
    int loopcnt;
    int temp = 0;
//loop:
void seq_read(){

    for (int i = 0; i < loopcnt; i++){
        temp <<= 1;
        if(a5 >= 0x80000000){//msb==1
            temp++;
        }
        printf("중간점검 temp: %x\n", temp);
        a5 <<= 1;
        wating_for_decoding --;
    totalBitsToRead --;
        puts("loop옴");
    }
}
int main () {
    a5 = bigendian[i];


check_last: 


printf("a5 = %x\n", a5);

if (a5 < 0x80000000){// msb == 0;
    a5 <<= 1;
    wating_for_decoding --;
    totalBitsToRead --;

    printf("0---- wating_for_decoding: %d\n", wating_for_decoding);

    if (wating_for_decoding >= 2){
        loopcnt = 2;
    }
    else if(wating_for_decoding == 1){
        loopcnt = 1;
        seq_read();
        i+=1;
        a5=bigendian[i];
        wating_for_decoding = 32;
        //convert_endian;
        loopcnt = 1;
    }
    else{
        i+=1;
        a5=bigendian[i];
        wating_for_decoding = 32;
        //convert_endian;
        loopcnt = 2;
    }
}
else{
    temp ++;
    a5 <<= 1;
    wating_for_decoding --;
    totalBitsToRead --;
    puts("1----");

    if(wating_for_decoding == 0){
        i+=1;
        a5=bigendian[i];
        wating_for_decoding = 32;
    }
    
    if (a5 < 0x80000000){ //10xxxxx
        a5 <<= 1;
        temp<<=1;
        wating_for_decoding --;
    totalBitsToRead --;
        puts("10----");
        if (wating_for_decoding >= 2){
            loopcnt = 2;
        }
        else if (wating_for_decoding == 1) { 
            loopcnt = 1;
            seq_read();
            i+=1;
            a5=bigendian[i];
        wating_for_decoding = 32;
            //convert_endian;
            loopcnt = 1;
        }
        else{
            i+=1;
            a5=bigendian[i];
        wating_for_decoding = 32;
            //convert_endian;
            loopcnt = 2;
        }
    }
    else{ //11xxxxx
        puts("11----");
        a5 <<= 1;
        temp<<=1;
        temp++;
        wating_for_decoding --;
    totalBitsToRead --;
        if(wating_for_decoding >= 3){
            loopcnt = 3;
        }
        else if(wating_for_decoding == 2){
            loopcnt = 2;
            seq_read();
            i+=1;
            a5=bigendian[i];
        wating_for_decoding = 32;
            //convert_endian;
            loopcnt = 1;
        }
        else if(wating_for_decoding == 1){
            loopcnt = 1;
            seq_read();
            i+=1;
            a5=bigendian[i];
        wating_for_decoding = 32;
            //convert_endian;
            loopcnt = 2;
        }
        else {
            i+=1;
            a5=bigendian[i];
        wating_for_decoding = 32;
            //convert_endian;
            loopcnt = 3;
        }
    }
   
}

seq_read();
printf("aft loop a5: 0x%x\n", a5);
goto decoding;


decoding:
    
printf("temp: 0x%x\n", temp);

    switch(temp){
        case 0: puts("rank0\n"); break;
        case 1: puts("rank1\n"); break;
        case 2: puts("rank2\n"); break;
        case 3: puts("rank3\n"); break;
        case 8: puts("rank4\n"); break;
        case 9: puts("rank5\n"); break;
        case 0xa: puts("rank6\n"); break;
        case 0xb: puts("rank7\n"); break;
        case 0x18: puts("rank8\n"); break;
        case 0x19: puts("rank9\n"); break;
        case 0x1a: puts("rank10\n"); break;
        case 0x1b: puts("rank11\n"); break;
        case 0x1c: puts("rank12\n"); break;
        case 0x1d: puts("rank13\n"); break;
        case 0x1e: puts("rank14\n"); break;
        case 0x1f: puts("rank15\n"); break;
    }
    
    puts("write in outreg\n");
    temp = 0;
    outlen ++;
    outregEmpty -= 4;
    
    printf("outlen: %d, outregEmpty: %d\n", outlen, outregEmpty);
    printf("wating_for_decoding: %d, totalBitsToRead: %d\n", wating_for_decoding, totalBitsToRead);
    if ( totalBitsToRead <=32 && wating_for_decoding== 0){
        puts("********마지막으로** convert->sw in mem\n");
        outlen >>= 1;
        printf("RESULT OUTLEN: %d\n", outlen);
        return 0;
    }
    if (wating_for_decoding == 0){
        i+=1;
        a5=bigendian[i];
    wating_for_decoding = 32;
    }

    if(outregEmpty == 0){
        puts("***convert->sw in mem\n");
        outregEmpty = 32;
    }

    printf("다음 loop 준비: total: %d\n---------------------\n", totalBitsToRead);
//    puts("잠만 멈춰봐");
//    return 0;
    if(totalBitsToRead <0){
    puts("total 0보다 작다!!!!");
    return 0;
    }
//
    if(totalBitsToRead <= wating_for_decoding){
    wating_for_decoding = totalBitsToRead;
}
goto check_last;


}







// too dirty    
//    if(0){
//        check_buf
//        if(0){
//            if(0){ rank 0; //000
//            }else { rank 1; //001
//            }
//        }else{
//            if(0){ rank 2; //010
//            }else { rank 3; //011
//            }
//        }
//    }else {
//        if(0){
//            if(0){
//                if(0){ rank 4; //1000
//                }else { rank 5; //1001
//                }
//            }else {
//                if(0){ rank 6; //1010
//                }else { rank 7; //1011
//                }
//            }
//        }else {
//            if(0){
//                if(0){ 
//                    if(0){ rank 8; //11000
//                    }else { rank 9; //11001
//                    }
//                }else {
//                    if(0){ rank 10; //11010
//                    }else { rank 11; //11011
//                    }
//                }
//            }else{
//                if(0){
//                    if(0){rank 12; //11100
//                    }else{ rank13; //11101
//                    }
//                }else{
//                    if(0){ rank 14; //11110
//                    }else{ rank 15; //11111
//                    }
//                }
//            }
//        }
//    }
//}



//    while (remain_bits >0){
//        int shift_countdown = 32;
//
//        if (remain_bits <= 32) {
//            puts("last part start\n");
//            decode(bigendian, remain_bits); //outreg에 담는 것까지만 한다.
//            // outp에 sw한다.
//            goto fin;
//        }
//        else{
//            puts("still remain\n");
//            decode(bigendian, shift_countdown); //outreg에 담는것까지만 한다.
//            // 1. byte align하게 다 담겼을 수도 있고 -> outp에 sw한다.
//            // 2. outreg가 남았을 수도 있고
//            // 3. outreg가 부족할 수도 있다. -> outp에 sw한다.
//            remain_bits -= 32;
//            //이 사이에 load word -> convert_endian 있어야 함.
//            printf("remain_bits: %d \n", remain_bits);
//
//            }
//    }
//fin:
//    puts("fin\n");
//
//        return 0;
//    }
//handling padding
//

//handling_chunk:
//
//    int shift_countdown = 32;
//    if (remain_bits <= 32){
//        puts("last part start\n");
//        decode(bigendian, remain_bits);
//        return;
//    }
//    else{
//        puts("still remain\n");
//        decode(bigendian, shift_countdown);
//        remain_bits -= 32;
//        //이 사이에 load word -> convert_endian 있어야 함.
//        printf("remain_bits: %d \n", remain_bits);
//
//        goto handling_chunk;
//        }
//
