#!/bin/sh

APPNAME="tccforth"
SOURCES="$(pwd)/../../csrc"
COMPILE="tcc -I . -D PF_SUPPORT_FP -D _DEFAULT_SOURCE -D _GNU_SOURCE -D uintptr_t=unsigned* -D intptr_t=int* -D PF_USER_FILEIO=\"pf_fcntl.h\" -D uint8_t=int -D NULL=0 -D int32_t=int -D uint32_t=unsigned -D uint16_t=unsigned -w -g -bench"
LINKING="tcc"

#OBJECTS="pf_cglue.o pf_clib.o pf_core.o pf_inner.o \
#	pf_io.o pf_io_no.o pf_main.o pf_mem.o pf_save.o \
#	pf_text.o pf_words.o pfcompil.o pfcustom.o pf_rshim.o"
OBJECTS="            pf_clib.o                      \
	pf_io.o pf_io_no.o           pf_mem.o            \
	                                pfcustom.o pf_tshim.o"

#${COMPILE} -c ${SOURCES}/pf_cglue.c -o pf_cglue.o
${COMPILE} -c ${SOURCES}/pf_clib.c -o pf_clib.o
#${COMPILE} -c ${SOURCES}/pf_core.c -o pf_core.o
#${COMPILE} -c ${SOURCES}/pf_inner.c -o pf_inner.o
${COMPILE} -c ${SOURCES}/pf_io.c -o pf_io.o
${COMPILE} -c ${SOURCES}/pf_io_no.c -o pf_io_no.o
#${COMPILE} -c ${SOURCES}/stdio/pf_io_st.c -o pf_io_st.o
#${COMPILE} -c ${SOURCES}/pf_main.c -o pf_main.o
${COMPILE} -c ${SOURCES}/pf_mem.c -o pf_mem.o
#${COMPILE} -c ${SOURCES}/pf_text.c -o pf_text.o
#${COMPILE} -c ${SOURCES}/pf_words.c -o pf_words.o
#${COMPILE} -c ${SOURCES}/pfcompil.c -o pfcompil.o
${COMPILE} -c ${SOURCES}/pfcustom.c -o pfcustom.o
${COMPILE} -c ${SOURCES}/pf_tshim.c -o pf_tshim.o
${LINKING} ${OBJECTS} -o ${APPNAME} ${LIBRARY}

echo "Done!"

exit 0
