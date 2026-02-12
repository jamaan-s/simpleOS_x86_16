**Bootloader and a Kernel from scratch 16bits assembly and C**.

Implemented Bootloader code using Assembly 16bits:
* Header for floppy image.
* Print to screen.
* Read and load kernel from other files into memory.

Implemented Kernel code using C and Assembly 16bits: 
* put, puts, put_f.
* printf.

## Credits:
This project was originally made by  [OliveStem](https://www.youtube.com/@olivestemlearning) on YT, [Playlist](https://www.youtube.com/playlist?list=PL2EF13wm-hWCoj6tUBGUmrkJmH1972dBB).

The original [Github project](https://github.com/scprogramming/JazzOS/)

## Run:
```bash
$ make run
```
or
```bash
$ qemu-system-i386 -fda build/main.img
```

## Build:
```bash
$ make
```
**build and run**:
```bash
$ make buildRun
```

## Debug:
**run qemu emulator with**:
```bash
$ make debug
```
**or**
```bash
$ qemu-system-i386 -fda build/main.img -s -S
```
**in another window terminal run gdb**:
```bash
$ gdb
```
**in gdb connect gdb to qemu**:
```bash-gdb
(gdb) target remote localhost:1234
```
**in gdb set breakpoint (at the start of the code address)**:
```bash-gdb
(gdb) br *0x7C00
```

## Tools used:
###### To run:
* qemu emulator (qemu-system-i386).
###### To build:
 **Required**:
* Nasm (to compile 16bits assembly files).
* Watcom 32bit compiler (to compile 16 bits C code). 
* mkfs.fat (to create a FAT12 filesystem).
* mcopy.
* make.
 **Other**:
* gdb (debugging).

 **Notes*:
	I used "Watcom 32bit" because the 64bit failed to install on WSL ubuntu VM, the 32bit worked just fine.

---
**This project was made and tested in side a Linux VM using (WSL with ubuntu image) on Win11**.
*WSL version: 2.6.3.0*
*Ubuntu image: 24.0.04*

