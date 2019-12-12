#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

/*
 * readfreq cpu interval base_khz
 * 
 * This program is not safe at all!
 * It should be called by freq_log.sh, or in the same way.
 */

int open_msr(int cpu)
{
	char path[256];

	snprintf(path, 256, "/dev/cpu/%d/msr", cpu);
	return open(path, O_RDONLY);
}

void close_msr(int fd)
{
	close(fd);
}

int read_msr(int fd, off_t address, uint64_t *value) {
	if (lseek(fd, address, SEEK_SET) < 0) {
		fprintf(stderr,
			"Could not seek to address 0x%lX\n",
			address);
		return -1;
	}

	read(fd, value, sizeof(uint64_t));

	return 0;
}

static void sig_handler(int signo)
{
	fprintf(stderr, "Caught signal %d. Stopping.\n", signo);
}

int main(int argc, char **argv)
{
	int cpu, fd;
	float interval; 	/* sampling interval in s */
	uint64_t base_khz;
	struct timespec ts, interval_ts;
	uint64_t d, m, a, dm, da, lm = 0, la = 0, freq;

	/* Parse arguments */
	cpu = (int) strtol(argv[1], NULL, 10);
	interval = strtof(argv[2], NULL);
	base_khz = (uint64_t) strtoul(argv[3], NULL, 10);

	interval_ts.tv_sec = (long) interval;
	interval_ts.tv_nsec = (interval - interval_ts.tv_sec) * 1000000000L;

	/* Signal handling */
	signal(SIGINT, sig_handler);

	fd = open_msr(cpu);
	if (fd < 0) {
		perror("Opening msr failed\n");
		return EXIT_FAILURE;
	}

	printf("time;frequency\n");
	while (1) {
		/* Read MSRs and date */
		clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
		read_msr(fd, 0xe7, &m);
		read_msr(fd, 0xe8, &a);

		/* Drop overflowing values */
		if (m < lm || a < la)
			continue;

		/* Compute frequency */
		dm = m - lm;
		da = a - la;
		freq = base_khz * da / dm;
		lm = m;
		la = a;

		/* Print it */
		d = ts.tv_sec * 1000000000 + ts.tv_nsec;
		printf("%lu;%lu\n", d, freq);

		/* Sleep until next interval */
		if (nanosleep(&interval_ts, NULL))
			break;
	}

	close_msr(fd);

	return EXIT_SUCCESS;
}
