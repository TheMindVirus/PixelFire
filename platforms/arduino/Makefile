APPNAME = pforth_avrgcc
SOURCES = $(shell pwd)/../../csrc
COMPILE = avr-gcc -x c --std=c99 -O2 --freestanding -D PF_SUPPORT_FP -D _DEFAULT_SOURCE -D _GNU_SOURCE
LINKING = avr-gcc --std=c89 -O2 --freestanding -lm -T arduino.ld
TESTING = avr-objdump

OBJECTS = pf_cglue.o pf_clib.o pf_core.o pf_inner.o pf_io.o pf_io_none.o pf_io_stdio.o pf_main.o pf_mem.o pf_text.o pf_words.o pfcompil.o pfcustom.o pf_pshim.o
#OBJECTS = pf_io.o pf_io_none.o pf_io_stdio.o pf_main.o pf_mem.o pf_text.o pf_words.o pfcustom.o pf_pshim.o
#OBJECTS = pf_main.o
#OBJECTS = pf_pshim.o

all:
	$(COMPILE) -c $(SOURCES)/pf_cglue.c -o pf_cglue.o
	$(COMPILE) -c $(SOURCES)/pf_clib.c -o pf_clib.o
	$(COMPILE) -c $(SOURCES)/pf_core.c -o pf_core.o
	$(COMPILE) -c $(SOURCES)/pf_inner.c -o pf_inner.o
	$(COMPILE) -c $(SOURCES)/pf_io.c -o pf_io.o
	$(COMPILE) -c $(SOURCES)/pf_io_none.c -o pf_io_none.o
	$(COMPILE) -c $(SOURCES)/stdio/pf_io_stdio.c -o pf_io_stdio.o
	$(COMPILE) -c $(SOURCES)/pf_main.c -o pf_main.o
	$(COMPILE) -c $(SOURCES)/pf_mem.c -o pf_mem.o
	$(COMPILE) -c $(SOURCES)/pf_text.c -o pf_text.o
	$(COMPILE) -c $(SOURCES)/pf_words.c -o pf_words.o
	$(COMPILE) -c $(SOURCES)/pfcompil.c -o pfcompil.o
	$(COMPILE) -c $(SOURCES)/pfcustom.c -o pfcustom.o
#	$(COMPILE) -c $(SOURCES)/pf_shim.c -o pf_shim.o
	$(COMPILE) -c $(SOURCES)/pf_pshim.c -o pf_pshim.o
	$(LINKING) $(OBJECTS) -o $(APPNAME) $(LIBRARY)
	$(TESTING) -s $(APPNAME)
	@echo "Executable written to $(APPNAME)"
