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
//uint8_t* extend(uint8_t *image, uint32_t width, uint32_t height);
//void process(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height);
//void process_asm(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height);

uint8_t getMax(uint8_t a, uint8_t b, uint8_t c){
	uint8_t tmp = a;
	if(b > tmp)
		tmp = b;
	if(c > tmp)
		tmp = c;
	return tmp;
}

uint8_t getMin(uint8_t a, uint8_t b, uint8_t c){
	uint8_t tmp = a;
	if(b < tmp)
		tmp = b;
	if(c < tmp)
		tmp = c;
	return tmp;
}


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
    int w, h, channels;
    int desiredChannels;
    unsigned char *image = stbi_load(input, &w, &h, &channels, desiredChannels);

    if (image == NULL) {
        puts(stbi_failure_reason());
        return 1;
    }

    desiredChannels = channels == 4 ? 2 : 1;
    size_t size = w * h * channels;
    size_t sizeGray = w * h * desiredChannels;
    
    //uint8_t *extended = extend(data, w, h);
    uint8_t *grayImage = malloc(sizeGray);

    clock_t begin = clock();

	for(unsigned char *img = image, *grayImg = grayImage;
						 img != img + size; img += channels, grayImage += desiredChannels){
		uint8_t max = getMax(*img, *img + 1, *img + 2);
		uint8_t min = getMin(*img, *img + 1, *img + 2);
		*grayImg =  (max + min) / 2;

		if(channels == 4){
			*(grayImg + 1) = *(img + 3);
		}
	}
    


    clock_t end = clock();
    printf("Processing time: %lf \n", (double)(end - begin) / CLOCKS_PER_SEC);
    fflush(stdout);

    if (stbi_write_png(output, w, h, desiredChannels, grayImage + (w+2)*3+3, (w+2)*3) == 0) {
        puts("Some png writing error\n");
        return 1;
    }

    free(grayImage);
    //free(extended);
    stbi_image_free(image);
    return 0;
}


//process one pixel
/*static inline int grey(int max, int min){
    return (max + min) / 2;
}


void process(uint8_t *image, uint8_t *copy, uint32_t w, uint32_t h) {
    int line = w * 3;
    register int i = line + 3;
    int max, min;

    for (register int y = 1; y < h; ++y){
        for (register int x = 1; x < w; ++x, i += 3) {
            max = getMax(image, i);
            min = getMin(image, i);
            //i - process red
            //i + 1 - process green
            //i + 2 - process blue
            copy[i] = grey(max, min);
            copy[i + 1] = grey(max, min);
            copy[i + 2] = grey(max, min);
        }
    }
}
*/
