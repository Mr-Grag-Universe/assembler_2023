#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <sys/param.h>
#include <stdarg.h>
#include <time.h>
#include <unistd.h>

#define	STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_resize.h"
#define	STB_IMAGE_RESIZE_IMPLEMENTATION
#include "stb/stb_image_write.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

#define BILLION  1000000000.0

extern int _handle_image(char *, char*, int, int, int);
extern int _strange_handle_image(char *, char*, int, int, int);

bool check_image(char * file_name) {
	int x, y, n, ok;
	ok = stbi_info(file_name, &x, &y, &n);
	return ok == 1;
}

unsigned char my_max(unsigned int n, ...) {
	va_list list;
	va_start(list, n);
	int m = -INT_MAX;
	for (unsigned int j = 0; j < n; ++j) {
		int x = va_arg(list, int);
		; m = MAX(x, m);
		if (m < x) {
			m = x;
		}
	}

	return m;
}

bool handle_image(unsigned char * new_data, unsigned char * data, int x, int y, int n) {
	// return _handle_image(new_data, data, x, y, n);
	data[x*y] = 1;
	// printf("%s", data);
	for (size_t i = 0; i < x*y*n; i+=n) {
		unsigned char a = data[i], b = data[i+1], c = data[i+2];
		if (n == 4) {
			new_data[i+3] = data[i+3];
		}
		unsigned char g = my_max(3, a, b, c); // MAX(a, MAX(b, c));
		memset(new_data+i, g, 3);
		// printf("(%d, %d, %d)=>%d;", a, b, c, new_data[i/3]);
	}
	return true;
}

bool strange_handle_image(unsigned char * new_data, unsigned char * data, int x, int y, int n) {
	// return _handle_image(new_data, data, x, y, n);
	data[x*y] = 1;
	// printf("%d, %d, %d\n", x, y, n);
	for (size_t i = 0; i < y; ++i) {
		for (size_t j = 0; j < x; ++j) {
			size_t ind = (i*x+j)*n;
			if ((double)(y-i) / (double)(x-j) < ((double)y) / ((double)x)) {
				memcpy(new_data+ind, data+ind, n);
				// printf("hi");
				continue;
			}
			
			unsigned char a = data[ind], b = data[ind+1], c = data[ind+2];
			if (n == 4) {
				new_data[ind+3] = data[ind+3];
			}
			unsigned char g = my_max(3, a, b, c); // MAX(a, MAX(b, c));
			memset(new_data+ind, g, 3);
			// printf("(%d, %d, %d)=>%d;", a, b, c, new_data[i/3]);
		}
	}
	return true;
}

#ifdef	INCLUDE_ASM_FUNC
#define handle_image _handle_image
#endif

#ifdef	INCLUDE_ASM_FUNC
#define strange_handle_image _strange_handle_image
#endif

int main(int argc, char ** argv) {

	if (argc < 3) {
		printf("minimum 2 arguments of comand line required!\n");
		return 1;
	}

	bool strange_or_not = false;
	if (argc >= 4) {
		if (!strcmp(*(argv+3), "strange")) {
			strange_or_not = true;
		} else if (!strcmp(*(argv+3), "normal")) {
			strange_or_not = false;
		} else {
		}
	}

#ifdef	INCLUDE_ASM_FUNC
	const char * message = "now you are running asm-enable program!\n";
	printf("%s", message);
#endif

	FILE * file;
	struct timespec start, end;
	double sum_time;

	// for (size_t i = 1; i < argc; ++i) {
		sum_time = 0;
		char * file_name = *(++argv);
		char * new_file_name = *(++argv); // malloc(strlen(file_name)+2);
		// strcpy(new_file_name+1, file_name);
		//  new_file_name[0] = '_';
		printf("%s => %s\n", file_name, new_file_name);
		
		if (!check_image(file_name)) {
			printf("this image: \"%s\" - is not ok", file_name);
			return -1;
		}

		for (size_t j = 0; j < 10; ++j) {
			int x, y, n;
			unsigned char * data = stbi_load(file_name, &x, &y, &n, 0);
			printf("%s: x: %d | y: %d | n: %d\n", file_name, x, y, n);

			if (n < 3) {
				int w, h, comp;
				stbi_write_png(new_file_name, x, y, n, data, 0);
				return 0;
			}

			char * new_data = malloc(x*y*n);
			clock_gettime(CLOCK_REALTIME, &start);
			bool err;
			if (strange_or_not) {
				err = strange_handle_image(new_data, data, x, y, n);
			} else {
				err = handle_image(new_data, data, x, y, n);
			}
			clock_gettime(CLOCK_REALTIME, &end);
			sum_time += (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
			if (!err)
				printf("handling falure!\n");
			if (data)
				stbi_image_free(data);

			if (new_data) {
				int w, h, comp;
				stbi_write_png(new_file_name, x, y, n, new_data, 0);
				free(new_data);
			}
		}
		// free(new_file_name);
		printf("time: %.10lf\n", sum_time/10);
	// }

	return 0;
}
