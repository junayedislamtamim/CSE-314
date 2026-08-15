#include "kernel/types.h"
#include "kernel/param.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"

struct syscall_stat {
  char syscall_name[16];
  int count;
  int accum_time;
};

int
main(int argc, char *argv[])
{
  struct syscall_stat st;

  if (argc == 1) {
    // no argument: print all syscalls
    for (int i = 1; i <= NUM_SYSCALLS; i++) {
      if (history(i, &st) >= 0) {
        printf("%d: syscall: %s, #: %d, time: %d\n", i, st.syscall_name, st.count, st.accum_time);
      }
    }
  } else if (argc == 2) {
    int n = atoi(argv[1]);
    if (history(n, &st) < 0) {
      fprintf(2, "history: invalid syscall number\n");
      exit(1);
    }
    printf("%d: syscall: %s, #: %d, time: %d\n", n, st.syscall_name, st.count, st.accum_time);
  } else {
    fprintf(2, "Usage: history [syscall_num]\n");
    exit(1);
  }

  exit(0);
}