#include <time.h>
#include <inttypes.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG
#include "stb_image.h"
#include "stb_image_write.h"

int work(char *input, char *output);
uint8_t* extend(uint8_t *image, uint32_t width, uint32_t height);
void process(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height);
void process_asm(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height);

int main(int argc, char **argv) {
    if(argc < 3) {
        printf("provide input and output files\n");
        return 0;
    }

    if(access(argv[1], R_OK) != 0) {
        printf("error opening input file %s\n", argv[1]);
        return 0;
    }

    int ret = work(argv[1], argv[2]);
    return ret;
}

int work(char *input, char *output) {
    int w, h;
    unsigned char *data = stbi_load(input, &w, &h, NULL, 3);

    if (data == NULL) {
        puts(stbi_failure_reason());
        return 1;
    }

    size_t size = w * h * 3;
    uint8_t *extended = extend(data, w, h);
    uint8_t *copy = malloc((w + 2) * (h + 2) * 3);

    clock_t begin = clock();

    #ifdef ASM
        process_asm(extended, copy, w + 2, h + 2);
    #else
        process(extended, copy, w + 2, h + 2);
    #endif

    clock_t end = clock();
    // printf("processing time: %lf\n", time_spent);
    printf("%lf", (double)(end - begin) / CLOCKS_PER_SEC);
    fflush(stdout);

    if (stbi_write_png(output, w, h, 3, copy + (w+2)*3+3, (w+2)*3) == 0) {
    // if (stbi_write_png(output, w + 2, h + 2, 3, copy, 0) == 0) {
        puts("Some png writing error\n");
        return 1;
    }

    free(copy);
    free(extended);
    stbi_image_free(data);
    return 0;
}

uint8_t* extend(uint8_t *image, uint32_t w, uint32_t h) {
    uint8_t *extended = malloc((w + 2) * (h + 2) * 3);

    int line1 = w * 3;
    int line2 = (w + 2) * 3;

    register int i1 = 0;
    register int i2 = line2 + 1 * 3;

    for (register int y = 0; y < h; ++y) {
        for (register int x = 0; x < w; ++x) {
            extended[i2] = image[i1];
            extended[i2+1] = image[i1+1];
            extended[i2+2] = image[i1+2];
            i1 += 3;
            i2 += 3;
        }
        i2 += 2 * 3;
    }

    i1 = line2;
    for (register int y = 1; y <= h; ++y) {
        extended[i1] = extended[i1+3];
        extended[i1+1] = extended[i1+4];
        extended[i1+2] = extended[i1+5];
        i1 += line2;
        extended[i1-3] = extended[i1-6];
        extended[i1-2] = extended[i1-5];
        extended[i1-1] = extended[i1-4];
    }

    memcpy(extended, extended + line2, line2);
    memcpy(extended + line2 * (h + 1), extended + line2 * h, line2);

    return extended;
}

//process one pixel
static inline int grey(int max, int min){
    return (max + min) / 2;
}

static inline int getMin(uint8_t *image, int index, int line){
    int tmp = image[index];
    if(tmp > image[index + 1]){
        tmp = image[index + 1];
    }

    if(tmp > image[index + 2]){
        tmp = image[index + 2];
    }
    return tmp;
}

static inline int getMax(uint8_t *image, int index, int line){
    int tmp = image[index];
    if(tmp < image[index + 1]){
        tmp = image[index + 1];
    }

    if(tmp < image[index + 2]){
        tmp = image[index + 2];
    }
    return tmp;
}


void process(uint8_t *image, uint8_t *copy, uint32_t w, uint32_t h) {
    int line = w * 3;
    int max, min;
    register int i = line + 3;

    for (register int y = 1; y < h; ++y){
        for (register int x = 1; x < w; ++x, i += 3) {
            max = getMax(image, i, line);
            min = getMin(image, i, line);
            //i - process red
            //i + 1 - process green
            //i + 2 - process blue
            copy[i] = grey(max, min);
            copy[i + 1] = grey(max, min);
            copy[i + 2] = grey(max, min);
        }
    }
}
