//
//  main.c
//  pthread
//
//  Created by pulinghao on 2022/7/20.
//

#include <stdio.h>
#include <pthread.h>

int pthread_create(pthread_t*, const pthread_attr_t*, void* (*)(void *), void *) __attribute__ ((weak));

int main(){
    if(pthread_create){
        printf("this is multiThread version");
    } else {
        printf("this is singleThread version");
    }
    return 0;
}
