#include <stdio.h>


int main () {
    int rank[16] = {0x0, 0x2, 0xa, 0xc, 0x1, 0x3, 0x4, 0x5};
    int n = 8;

// goto문
    int i = 0;
    int j = 0;

    if (i >= 16) goto done;
loopi:
    j = 0;

    if (j >=8) goto done;

loopj:
    if (i == rank[j]){
        goto iupdate;
    }
    j++;
    if(j < 8) goto loopj;

    rank[n++] = i;

iupdate:
    i++;
    if (i < 16) goto loopi;

// dowhile문
//    int i = 0;
//    if (i >= 16) goto done;
//    do {
//        int flag = 0;
//        int j = 0;
//
//        if (j >=8) goto done;
//        do {
//            if (i == rank[j]){
//                flag = 1;
//                break;
//            }
//            j++;
//        } while (j < 8);
//
//        if (!flag) {
//            rank[n++] = i;
//        }
//        i++;
//    } while (i < 16);

done:

//while문
//   int i = 0;
//   while (i < 16){
//       int flag = 0;
//       int j = 0;
//
//       while (j < 8){
//           if (i == rank[j]){
//               flag = 1;
//               break;
//           }
//           j++;
//       }
//
//       if (!flag){
//           rank[n++] = i;
//       }
//
//       i++;
//   }

// for문
//    for (int i = 0; i < 16; i++){
//        int flag = 0;
//        for (int j = 0; j < 8; j++){
//            if (i == rank[j]){
//                flag = 1;
//                break;
//            }
//            //TODO : delete
//            printf("bfr: i:%x, j:%d, rank[j]:%x, flag: %d\n", i, j, rank[j], flag);
//        }
//        if (!flag) {
//            rank[n++] = i;
//            printf("aft: i:%x, rank[n]:%x\n", i, rank[n-1]);
//        }
//    }

    for (int i = 0; i < 16; i++){
        printf("i: %d, val: %x\n", i, rank[i]);
    }

}


