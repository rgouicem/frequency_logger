readfreq: readfreq.c
	gcc -O3 -Wall -Wextra $< -o $@

clean:
	rm -rf readfreq *~

.PHONY: clean
