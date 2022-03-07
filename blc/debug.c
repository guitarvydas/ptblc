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
#include <ctype.h>
#include <stdio.h>
#include <wchar.h>
#endif
#include "blc.h"

const char *GetOpName(int x) {
  switch (x) {
    case VAR:
      return "var";
    case APP:
      return "app";
    case ABS:
      return "abs";
    case IOP:
      return "iop";
    default:
      return "wut";
  }
}

int GetDepth(struct Closure *env) {
  int i;
  for (i = 0; env && env != &root; ++i) {
    env = env->next;
  }
  return i;
}

void PrintClosure(struct Closure *c, const char *name, int indent, FILE *f) {
  int i, j;
  while (c && c != &root) {
    for (j = 0; j < indent; ++j) {
      if (j) {
        fputs("│ ", f);
      } else {
        fputs("  ", f);
      }
    }
    fputs(name, f);
    fputs(": ", f);
    Print(c->term, 0, GetDepth(c->envp), f);
    fprintf(f, " +%d\n", c->refs);
    PrintClosure(c->envp, "envp", indent + 1, f);
    c = c->next;
  }
}

void PrintMachineState(FILE *f) {
  int i;
  static int op;
  struct Closure *c;
  fputc('\n', f);
  for (i = 0; i < 80; ++i) fputwc(L'─', f);
  fprintf(f, "%d\n", op++);
  fprintf(f, "   ip      %ld | op %d %s | arg %d | end %ld\n", ip, mem[ip],
          GetOpName(mem[ip]), mem[ip + 1], end);
  fputs(" term      ", f);
  Print(ip, 0, GetDepth(envp), f);
  fputc('\n', f);
  fputc('\n', f);
  PrintClosure(contp, "contp", 1, f);
  fputc('\n', f);
  PrintClosure(envp, "envp", 1, f);
  fputc('\n', f);
  PrintClosure(frep, "frep", 1, f);
}

void PrintExpressions(FILE *f, char alog, char vlog) {
  int i, d;
  struct Closure *p, ps;
  ps.term = ip;
  ps.next = contp;
  ps.envp = envp;
  for (p = &ps; p; p = p->next) {
    Print(p->term, 1, GetDepth(p->envp), f);
    if (p->next) fputc(' ', f);
  }
  if (alog) {
    fputs(" ⟹ ", f);
    switch (mem[ip]) {
      case VAR:
        fprintf(f, "var[%d]", mem[ip + 1]);
        break;
      case APP:
        fputs("app[", f);
        Print(ip + 2 + mem[ip + 1], 1, GetDepth(envp), f);
        fputc(']', f);
        break;
      case ABS:
        if (contp) {
          fputs("abs[", f);
          Print(ip + 1, 1, GetDepth(envp), f);
          fputc(']', f);
        } else {
          fprintf(f, "bye[%d]", mem[ip + 2]);
        }
        break;
      case IOP:
        if (ip < 22) {
          if (!binary) {
            fprintf(f, "put[%c]", '0' + (int)(ip & 1));
          } else if (mem[ip + 1] & 1) {
            fprintf(f, "put[0%hho '%c']", co, isprint(co) ? co : '.');
          } else {
            fprintf(f, "wr%d[0%hho]", (int)(ip & 1), co);
          }
        } else {
          fputs("gro", f);
        }
        break;
      default:
        break;
    }
  }
  if (vlog) {
    d = GetDepth(envp);
    for (i = 0, p = envp; p->term != -1; ++i, p = p->next) {
      fputc('\n', f);
      fputc('\t', f);
      PrintVar(style != 1 ? i : d - 1 - i, f);
      fputc('=', f);
      Print(p->term, 0, GetDepth(p), f);
    }
  }
  fputc('\n', f);
}
