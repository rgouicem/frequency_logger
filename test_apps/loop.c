#include <stdio.h>
#include <signal.h>
#include <time.h>
#include <stdint.h>

static int stop;

static void sig_handler(int signo)
{
	stop = 1;
}

int main()
{
	struct timespec ts;
	uint64_t d;

	signal(SIGINT, sig_handler);
	clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
	d = ts.tv_sec * 1000000000 + ts.tv_nsec;
	printf("%lu;start loop;green\n", d);
	while (!stop) {}
	clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
	d = ts.tv_sec * 1000000000 + ts.tv_nsec;
	printf("%lu;end loop;red\n", d);
	return 0;
}
