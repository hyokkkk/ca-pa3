#include <stdio.h>


//test0 len:21
//    unsigned int bigendian[] = {0xb43088c0, 0x89659708, 0x891e168b, 0xa1d10383, 0x8d69400};
//    int waiting_for_decoding = 28;
//    int totalBitsToRead = (0x18<<3)-32-4-7;


//test1 len: 10
//   unsigned int bigendian[3] = {0x8233f9a0, 0x8921f915, 0x636c0000};
//   int waiting_for_decoding = 28; //padding 다 없앤 후
//   int totalBitsToRead = 74;

//test2 len: 32+12=44
 unsigned int bigendian[] = {0x8a162130, 0x38303432, 0x38984509, 0x247d3004,
                            0x9b4c6cc0, 0xf1672989, 0x2041499a, 0x162131d1,
                            0x83b3a4c5, 0x09057c00};

int waiting_for_decoding = 28;
int totalBitsToRead = 306;


//test3 len: 3
//   unsigned int bigendian[3] = {0x68820000};
//   int waiting_for_decoding = 28;
//  int totalBitsToRead = 18;
    int i = 0;
    int a5 = 0;
    int outregEmpty=32;
    int outlen=0;
    int loopcnt;
    int temp = 0;


void seq_read(){
read:
    temp <<= 1;
    if(a5 >= 0x80000000){ temp++; }
    a5 <<=1;
    waiting_for_decoding --;
    totalBitsToRead --;
    loopcnt--;
    if(loopcnt>0) {
    goto read;}
ret:
    return;
}
// dowhileloop
//    if(j >= loopcnt){
//        return;
//    }
//    do{
//        temp <<= 1;
//        if(a5 >= 0x80000000){ temp ++; }
//        a5 <<= 1;
//        waiting_for_decoding --;
//        totalBitsToRead --;
//        j ++;
//    } while(j < loopcnt);

//    while(j < loopcnt){
//        temp <<= 1;
//        if(a5 >= 0x80000000){
//            temp++;
//        }
//        a5 <<= 1;
//        waiting_for_decoding --;
//        totalBitsToRead --;
//        j ++;
//    }


void load_data(){
        i+=1;
        a5=bigendian[i];
        waiting_for_decoding = 32;
        //convert_endian;
}
void shift_read_data(){
    a5 <<= 1;
    waiting_for_decoding --;
    totalBitsToRead --;
}

int main () {

    a5 = bigendian[i];

decodingLoop:
    temp = 0;
if (a5 < 0x80000000){// msb == 0;
    shift_read_data();

    if (waiting_for_decoding >= 2){
        loopcnt = 2;
    }
    else if(waiting_for_decoding == 0){
        load_data();
        loopcnt = 2;
    }
    else {
        loopcnt = 1;
        seq_read();
        load_data();
        loopcnt = 1;
    }
    
}
else{
    temp ++;
    shift_read_data();

    if(waiting_for_decoding == 0){
        load_data();
    }

    if (a5 < 0x80000000){ //10xxxxx
        temp<<=1;
        shift_read_data();

        if (waiting_for_decoding >= 2){
            loopcnt = 2;
        }
        else if( waiting_for_decoding ==0){
            load_data();
            loopcnt = 2;
        }
        else {
            loopcnt = 1;
            seq_read();
            load_data();
            loopcnt = 1;
        }
    }
    else{ //11xxxxx
        temp<<=1;
        temp++;
        shift_read_data();

        if(waiting_for_decoding >= 3){
            loopcnt = 3;
        }
        else if(waiting_for_decoding == 2){
            loopcnt = 2;
            seq_read();
            load_data();
            loopcnt = 1;
        }
        else if(waiting_for_decoding ==0){
            load_data();
            loopcnt = 3;
        }
        else {
            loopcnt = 1;
            seq_read();
            load_data();
            loopcnt = 2;
        }
    }
}

seq_read();



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

    if (waiting_for_decoding == 0){
        if (totalBitsToRead <= 32){
            puts("convert-> store in memory");
            outlen >>= 1;
            printf("outlen: %d\n", outlen);
            return 0;
        }
        load_data();
    }
    if(outregEmpty == 0){
        puts("convert -> store in mem");
        outregEmpty = 32;
    }
    if(totalBitsToRead <0){
        return 0;
    }
    if(totalBitsToRead <= waiting_for_decoding){
        waiting_for_decoding = totalBitsToRead;
    }
goto decodingLoop;
}

