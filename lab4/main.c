#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

double my_pow(double x, unsigned int n) {
	double res = x;
	while (n-- > 1) {
		res *= x;
	}
	return res;
}

double formula(double x, unsigned int n_e) {
	double y = x;
	double S = 0;
	size_t n = 1;
	char sign = 1;
	double e = 1/my_pow(10.0, n_e+1);
	printf("%10lf\n", e);
	double delta = 0;
	do {
		delta = y*sign/n;
		S += delta;
		y *= x*x;
		n += 2;
		sign = -sign;
	} while (fabs(delta) > e);
	return S;
}

int main() {
	double x = 0;
	unsigned int precision = 0;
	
	// вводим значения x и точности вычисления
	printf("enter your x: ");
	scanf("%lf", &x);
	printf("enter number of signs abter comma: ");
	scanf("%d", &precision);

	printf("%lf, %d\n", x, precision);

	printf("result: %lf", formula(x, precision));

	return 0;
}
