#include <stdio.h>
#include <signal.h>
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

int main()
{
	uint64_t d;

	signal(SIGINT, sig_handler);
	d = rdtsc();
	printf("%lu;start loop;green\n", d);
	while (!stop) {}
	d = rdtsc();
	printf("%lu;end loop;red\n", d);
	return 0;
}
