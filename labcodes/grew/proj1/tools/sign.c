#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>

int main(int argc, char *argv[]) {
    struct stat st;
    
    if (3 != argc) {
        fprintf(stderr, "Usage: <input filename> <output filename>");
        return -1;
    }

    if (0 != stat(argv[1], &st)) {
        fprintf(stderr, "Error opening file '%s': %s\n", argv[1], stderror(errno));
        return -1;
    }

    printf("'%s' size: %lld bytes\n", argv[1], (long long)st.st_size);
    if (st.st_size > 510) {
        fprintf(stderr, "%lld >> 510!!\n", (long long)st.st_size);
        return -1;
    }

    char buf[512];
    // 把buf内容都设置为0
    memset(buf, 0, sizeof(buf));
    FILE *ifp = fopen(argv[1], "rb");
    int size = fread(buf, 1, st.st_size, ifp);
    if (size != st.st_size) {
        fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
        return -1;
    }

    fclose(ifp);
    buf[510] = 0x55;
    buf[511] = 0xAA;
    
    FILE *ofp = fopen(argv[2], "wb+");
    size = fwrite(buf, 1, 512, ofp);
    
    if (512 != size) {
        fprintf(stderr, "write '%s' error, size is %d.\n", argv[2], size);
        return -1;
    }

    fclose(ofp);   
    printf("build 512 bytes boot sector: '%s' success!\n", argv[2]);
    return 0;
}