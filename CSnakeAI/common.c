#include <stdio.h>
#include "common.h"

void null_check(void *ptr) {
  if (!ptr) {
    perror("Memory unallocated");
    exit(EXIT_FAILURE);
  }
}
