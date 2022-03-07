/*-*- mode:c;indent-tabs-mode:nil;c-basic-offset:2;tab-width:8;coding:utf-8 -*-│
│vi: set net ft=c ts=2 sts=2 sw=2 fenc=utf-8                                :vi│
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2022 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Copying of this file is authorized only if (1) you are Justine Tunney, or    │
│ (2) you make absolutely no changes to your copy.                             │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES     │
│ WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF             │
│ MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR      │
│ ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES       │
│ WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN        │
│ ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF      │
│ OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.               │
╚─────────────────────────────────────────────────────────────────────────────*/
#ifndef __COSMOPOLITAN__
#include <stdio.h>
#include <wchar.h>
#endif
#include "blc.h"

extern wint_t get_char ();

char GetBit(FILE* f) {
  wint_t c;
  char comment;
  static wint_t buf, mask;
  if (!binary) {
    for (comment = 0;;) {
      c = get_char();
      if (c == -1) break;
      if (!comment) {
        fflush(stdout);
        if (c == ';') {
          comment = 1;
        } else if (!iswspace(c) && c != '(' && c != ')' && c != '[' &&
                   c != ']') {
          if (c != -1) c &= 1;
          break;
        }
      } else if (c == '\n') {
        comment = 0;
      }
    }
  } else if (mask) {
    c = !!(buf & mask);
    mask >>= 1;
  } else {
    c = get_char ();
    if (c != -1) {
      buf = c;
      c = (c >> 7) & 1;
      mask = 64;
    }
  }
  return c;
}
