//
//  main.m
//  LearnMac
//
//  Created by zhanghuiqiang on 2021/1/23.
//

#import <Foundation/Foundation.h>

struct china {
     int data;
     char name[100];
     //给结构体内部在此定义一个结构体，创建结构体变量，这个变量会直接当作成员
     //但是没有创建结构体的实例
     //再次定义的结构体内部的变量 会被当作母结构体的成员变量
     struct guiyang
     {
         char str[100];
         int num;
     }b1;
//     struct guiyang b1;
 };
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        struct china c1;
        c1.data = 100;
        c1.b1.num = 200;
        sprintf(c1.b1.str,"ad");
        struct guiyang g1;
        sprintf(g1.str,"ad");
        printf("%d,%s",c1.b1.num,c1.b1.str);
        getchar();
    }
    return 0;
}

