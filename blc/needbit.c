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
#include "blc.h"

char NeedBit(FILE* f) {
  char b = GetBit(f);
  if (b == -1) Error(9, "UNEXPECTED EOF");
  return b;
}
