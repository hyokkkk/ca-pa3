#include <stdio.h>

void decode(int, int);
void handling_chunk(int, int);
int main () {
    int bigendian = 0x26882000;
    int remain_bits = 33; //padding 다 없앤 후
    handling_chunk(bigendian, remain_bits);

//handling padding
//

}

void handling_chunk(int bigendian, int remain_bits){
    int shift_countdown = 32;
    if (remain_bits <= 32){
        puts("last part start\n");
        decode(bigendian, remain_bits);
        return;
    }
    else{
        puts("still remain\n");
        decode(bigendian, shift_countdown);
        remain_bits -= 32;
        printf("remain_bits: %d \n", remain_bits);
        handling_chunk(bigendian, remain_bits);

        }

    }

void decode(int bigendian, int shift_countdown){
    puts("start decode\n");
    while(shift_countdown > 0){
        shift_countdown --;
        printf("shift: %d\n", shift_countdown);
    }
    return;
}




