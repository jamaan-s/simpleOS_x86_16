#include "./stdio/stdio.h"
#include "disk/asmDisk.h"
#include "stdint.h"

void _cdecl cstart_() {
  uint8_t error;
  printf("Kernel: simpleOS Booted!\r\n");

  x86_Disk_Reset(0, &error);
  printf("Kernel: Testing Error code: %d\r\n", error);
}