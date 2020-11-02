#include <stdio.h>

//void decode(int bigendian, int shift_countdown){
//    puts("start decode\n");
//    while(shift_countdown > 0){
//
//        shift_countdown --;
//        printf("shift: %d\n", shift_countdown);
//    }
//    return;
//}
    unsigned int bigendian[3] = {0x68820000};
    int i = 0;
    int a5 = 0;
    int needdecoding = 32; //padding 다 없앤 후
    int totalBitsToRead = 18;
    int outregEmpty=32;
    int outlen=0;
    int loopcnt;
    int temp = 0;
//loop:
void loop(){

    for (int i = 0; i < loopcnt; i++){
        temp <<= 1;
        if(a5 >= 0x80000000){//msb==1
            temp++;
        }
        a5 <<= 1;
        needdecoding --;
    }
}
int main () {
    a5 = bigendian[i];
printf("a5 = %x\n", a5);

if (a5 < 0x80000000){// msb == 0;
    a5 <<= 1;
    needdecoding --;

    printf("msb:0, needdecoding: %d\n", needdecoding);

    if (needdecoding >= 2){
        loopcnt = 2;
    }
    else if(needdecoding == 1){
        loopcnt = 1;
        loop();
        i+=1;
        a5=bigendian[i];
        //convert_endian;
        loopcnt = 1;
    }
    else{
        i+=1;
        a5=bigendian[i];
        //convert_endian;
        loopcnt = 2;
    }
}
else{
    temp ++;
    needdecoding --;
    if (a5 < 0x80000000){ //10xxxxx
        a5 <<= 1;
        needdecoding --;
        if (needdecoding >= 2){
            loopcnt = 2;
        }
        else if (needdecoding == 1) { 
            loopcnt = 1;
            loop();
            i+=1;
            a5=bigendian[i];
            //convert_endian;
            loopcnt = 1;
        }
        else{
            i+=1;
            a5=bigendian[i];
            //convert_endian;
            loopcnt = 2;
        }
    }
    else{ //11xxxxx
        a5 <<= 1;
        temp++;
        needdecoding --;
        if(needdecoding >= 3){
            loopcnt = 3;
        }
        else if(needdecoding == 2){
            loopcnt = 2;
            loop();
            i+=1;
            a5=bigendian[i];
            //convert_endian;
            loopcnt = 1;
        }
        else if(needdecoding == 1){
            loopcnt = 1;
            loop();
            i+=1;
            a5=bigendian[i];
            //convert_endian;
            loopcnt = 2;
        }
        else {
            i+=1;
            a5=bigendian[i];
            //convert_endian;
            loopcnt = 3;
        }
    }
}

loop();
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
    outlen ++;
    outregEmpty -= 4;
    
    printf("outlen: %d, outregEmpty: %d\n", outlen, outregEmpty);

    if (needdecoding == 0 && totalBitsToRead == 32){
        outlen >>= 1;
        return outlen;
    }
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
