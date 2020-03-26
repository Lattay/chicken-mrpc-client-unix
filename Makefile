PREFIX=
CSC=
ifeq ($(CSC),)
ifeq ($(PREFIX),)
CSC=csc
else
CSC=$(PREFIX)/bin/csc
endif
endif

CSC_OPTIONS=

.PHONY: all clean

all: mrpc-client-unix.so

mrpc-client-unix.so: src/mrpc-client-unix.scm
	$(CSC) $(CSC_OPTIONS) -s -j mrpc-client-unix -o $@ $<
	$(CSC) $(CSC_OPTIONS) mrpc-client-unix.import.scm -dynamic

clean:
	rm -f *.so *.sh *.import.scm *.link *.o
