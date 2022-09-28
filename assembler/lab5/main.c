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
void process(uint8_t *image, uint8_t *copy, int width, int height, int original_channels, int desired_channels);
void process_asm(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height);

int main(int argc, char **argv) {
    if(argc < 3) {
        printf("Provide input and output files.\n");
        return 0;
    }

    if(access(argv[1], R_OK) != 0) {
        printf("Error opening input file: %s\n", argv[1]);
        return 0;
    }

    int ret = work(argv[1], argv[2]);
    return ret;
}

int work(char *input, char *output) {
    int w, h, original_no_channels;
    int desired_no_channels;
    unsigned char *data = stbi_load(input, &w, &h, &original_no_channels, desired_no_channels);
    if (data == NULL) {
        puts(stbi_failure_reason());
        return 1;
    }
	
    size_t size = w * h * original_no_channels;
    int gray_channels = 4 ? 2 : 1;
    size_t gray_image_size = w * h * gray_channels; 
    
	uint8_t *copy = malloc(gray_image_size);


    //uint8_t *copy = malloc((w + 2) * (h + 2) * 3);

    clock_t begin = clock();

    #ifdef ASM
        process_asm(extended, copy, w, h);
    #else
        process(data, copy, w, h, original_no_channels, desired_no_channels);
    #endif

    clock_t end = clock();
    printf("Processing time: %lf \n", (double)(end - begin) / CLOCKS_PER_SEC);
    fflush(stdout);

    if (stbi_write_png(output, w, h, gray_channels, copy, 0) == 0){
    // if (stbi_write_png(output, w + 2, h + 2, 3, copy, 0) == 0) {
        puts("Some png writing error\n");
        return 1;
    }

    free(copy);
    stbi_image_free(data);
    return 0;
}

//process one pixel
static inline int get_max(int num1, int num2, int num3){
	int tmp = num1;
	if(tmp < num2){
		tmp = num2;
	}
	if(tmp < num3){
		tmp = num3;
	}

	return tmp;
}

static inline int get_min(int num1, int num2, int num3){
	int tmp = num1;
	if(tmp > num2){
		tmp = num2;
	}
	if(tmp > num3){
		tmp = num3;
	}

	return tmp;
}

void process(uint8_t *image, uint8_t *copy, int w, int h, int channels, int gray_channels) {
    size_t size = w * h * channels;
    int max, min;

   	for(uint8_t *p = image, *pg = copy; p != image + size; p += channels, pg += gray_channels){
   		max = get_max(*p, *p + 1, *p + 2);
   		min = get_min(*p, *p + 1, *p + 2);
   		*pg = (uint8_t) (max + min) / 2;
   		if(channels == 4){
   			*(pg + 1) = *(p + 3);
   		}
   	}
}
