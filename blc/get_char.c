#include <stdio.h>
#include <assert.h>
#include <ctype.h>
#include <locale.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <unistd.h>
#include <wchar.h>
int ix = 0;
char input[] = {'0', '0', '1', '0', '0', '1', '0', '1'};
wint_t get_char () {
    if (ix >= 8) {
        return (wint_t)-1;
    } else {
        return ((wint_t)input[ix++]);
    }
}