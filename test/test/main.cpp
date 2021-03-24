//
//  main.cpp
//  test
//
//  Created by zhanghuiqiang on 2021/3/19.
//

#include <iostream>

void swap1(int a,int b){
    int temp = a;
    a = b;
    b = temp;
}


void swap2(int &a, int &b)
{
    int temp = a;
    a = b;
    b = temp;
}

void swap3(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}
int main(int argc, const char * argv[]) {
    // insert code here...
    int a = 1;
    int b = 2;
//    swap1(a, b);
//    std::cout << a <<" "<< b <<std::endl;
    swap2(a, b);
    std::cout << a <<" "<< b <<std::endl;
    a = 1;
    b = 2;
    swap3(&a, &b);
    std::cout << a <<" "<< b <<std::endl;
    return 0;
}
