
all: readfreq test_apps

readfreq: readfreq.c
	gcc -O3 -Wall -Wextra $< -o $@

test_apps:
	make -C test_apps

clean:
	make -C test_apps clean
	rm -rf *~

mrproper: clean
	make -C test_apps mrproper
	rm -rf readfreq

.PHONY: clean all mrproper test_apps
