```
!!! WARNING !!!
The binaries provided in this source tree are generated for Componentry Kit Builds.
The intended usecase of these binaries is for use with binary inspection tools.
Please do not run the executables on the native platform except for tests.

[build_targets]
arduino /* avr-gcc */
linux-crossbuild-amiga
linux-crossbuild-atari
linux-crossbuild-riscv64 /* riscv64-linux-gnu-gcc */
mingw-crossbuild-linux
pico /* arm-none-eabi-gcc */
unix
win32
multimc-oc2 /* tcc */ /* gets truncated to 8 letter filenames on fdisk->mkdosfs->mount /dev/vdb */
```
