Count words
===========

On comp.lang.forth Ben Hoyt posted a problem of counting word frequencies.
His conclusions can be found at [Performance comparisons](https://benhoyt.com/writings/count-words).

The picoLisp and Ada entry is a modified version of a [Rosetta-code problem](http://rosettacode.org/wiki/Word_frequency).

The interesting pieces are the Ada, K and picoLisp entries.

My conclusions:

* the fastest is C, which is roughly 6x faster than the AWK entry
* on macOS the simple C++ version is 3x slower than the GNAT Ada entry
* picoLisp and SBCL performance is roughly the same, which is surprising
  (picoLisp is a pure interpreted LISP, SBCL is compiled)
* if I type 60x more characters than the K version, then I can get 10x 
  speedup with C
* GPCP Component Pascal compiles to Java, but it uses a custom hash table
  and buffered output, so it is 2x faster than the optimized Java version
* if the output is not buffered, it takes a significant time to produce the
  results

## Results

| Language   | Chars | Elapsed time |
| ---------- | ----- | ------------ |
| K          |    74 |        2962  |
| Shell      |    84 |       10971  |
| AWK        |   141 |        1826  |
| picoLisp   |   423 |        6380  |
| CommonLisp |  1004 |        5696  |
| C++        |  2304 |         474  |
| GForth     |  3003 |        1819  |
| Ada        |  3203 |        3442  |
| C          |  4295 |         278  |
| SwiftForth |  4173 |         564  |
| iForth     |  4108 |         470  |
| ComponentPascal |  6502 |    780  |
| Java       |  2870 |        2118  |


pahihu 29mar2021
