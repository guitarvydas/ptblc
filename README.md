ptblc

# Elevator Pitch (Synopsis)
Pipeline that macro-expands `λ [[$pair $false] [[$pair $true] $nil]]` into `λ [[ λλλ0 λλ0 ] [[ λλλ0 λλ1 ] λλ0 ]]`, then parses that into executable code in various languages (Python, JS, WASM, sectorlisp, sectorblc, etc., etc.).

WIP.
# Goal
Convert lambda-calculus to code in Python, JS, WASM, etc, etc.

Q: [open question]: does Lambda Calculus / sectorblc / sectorlisp lead to Atoms of Software?

# Simplicity
I am most interested simplicity.

The goal of `sectorlisp` and `sectorblc` is smallness, with a side-effect of simplicity.

Simplicity and smallness are related, but not necessarily the same thing.

Simplicity is defined as "lack of nuance".

Notational economy is a form of simplicity.

This leads to the question "What is the simplest notation for a given problem?".

If you are using a notation that isn't suited to a problem, you begin to see *tells*.  A tell often manifests itself as statements like "multitasking is difficult". To emphasize, note that a *tell* doesn't mean that a problem is complicated, only that the notation being used is unsuited to describing the problem and results in accidental complexity (aka epicycles).

This question further leads to the observation that there *cannot* be a *single* notation for any sizable problem/solution.  You might choose a notation that is a local minimum, and describes many aspects of the problem/solution, but you end up playing whack-a-mole with the aspects that aren't easily-described by the notation. Clever people (aka "smart" people) can often find work-arounds to notational complexity, but, their time would be better-spent thinking about higher-level concepts than figuring out notational work-arounds.

It's "turtles all the way down". Once you find a suitable notation, other suitable simplifications suggest themselves. Fractally.

# Multiple Notations
I believe in choosing the best notation(s) for the job.

Parsers are good for parsing. Parsers are better than, say, parsing combinators, since parsers use (only) a syntax for parsing, without trying to appease GPLs (General Programming Languages).

Relational Programming is good for searching and querying.  In my mind, PROLOG is better than Loops and Recursion for this kind of thing (querying).  Some day, I will try to apply miniKanren to this stuff. (Note that I view core.logic as miniKanren force-fitted into a GPL called Clojure).

The ultimate goal is to compose solutions using many syntaxes and paradigms.

(Note that I, also, think that DaS - Diagrams - is a valid syntax.  We shouldn't be restricted into thinking textual-only.)

I believe in smallness of notation ("Does it fit on a T-Shirt?") which isn't necessarily the same as smallness of code.

# Atoms of Software
I think that it is important to take things apart and strip them down to their bare essentials.

Then, build them back up into "better" development tools, using things like, say, parsers and rewriters (I am not restricted to using parsers and rewriters, but they do look intriguing at the moment).

# Disclaimer
I believe in "showing my work".  This is WIP.
# Contributing
I will gladly impart these ideas to anyone with an open mind - experience not necessary.
# Parsing
I use `prep` which is kinda like `sed` on steroids.

`Prep` uses `Ohm-JS` grammars and `glue` rewriting rules. 

# Usage
See `Makefile`, which uses `run.bash`

# References
[prep](https://guitarvydas.github.io/2022/03/05/Prep.html)
[prep yourube](https://guitarvydas.github.io/2022/01/20/PREP-Tool.html)
[Ohm-JS](https://github.com/harc/ohm)
[sector blc](https://justine.lol/lambda/)
[sector lisp](https://justine.lol/sectorlisp2/)
[glue - see links](https://guitarvydas.github.io/2021/09/15/ABC-Glue.html)
