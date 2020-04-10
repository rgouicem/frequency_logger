#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

static int stop;

static inline uint64_t rdtsc(void)
{
	uint64_t a, d;

	asm volatile ("rdtsc" : "=a" (a), "=d" (d));
	return (d << 32) | a;
}

static void sig_handler(int signo)
{
	stop = 1;
}

int main(int argc, char **argv)
{
	uint64_t d, start, duration = 0;

	if (argc > 1)
		duration = strtoul(argv[1], NULL, 10);

	signal(SIGINT, sig_handler);
	start = rdtsc();
	printf("%lu;start loop;green\n", start);

	while (!stop) {
		d = rdtsc();
		if (!duration)
			continue;
		if (d - start > duration)
			break;
	}

	d = rdtsc();
	printf("%lu;end loop;red\n", d);

	return 0;
}
