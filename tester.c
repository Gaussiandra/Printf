extern void myPrintf();

int main() {
    myPrintf("Hello!1 %c%c %c aboba %s %s z %d %d %o-%o %b %x %%%c\n",
              'a', 'b', 'c', "amogus", "beef2", 22334455, 123, 88, 16, 15, 255, '0');

    myPrintf("\n"); 

    myPrintf("%d %d %d %d %d!! %d %d %d %d %d, %d, %d %d. %d, AND I %s %x %d%%%c%b\n", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
                                                                "love", 3802, 100, 33, 15);

    for (int i = 0; i < 10; ++i) {
        myPrintf("%d\n", i);
    }

    return 0;
}