Count words
===========

On comp.lang.forth Ben Hoyt posted a problem of counting word frequencies.
His conclusions can be found at [Performance comparisons](https://benhoyt.com/writings/count-words).

The picoLisp and Ada entry is a modified version of a [Rosetta-code problem](http://rosettacode.org/wiki/Word_frequency).

The interesting pieces are the Ada, K and picoLisp entries.

My conclusions:

* the fastest is C, which is roughly 6x faster than the AWK entry
* on macOS the simple C++ version is 3x slower than the GNAT Ada entry,
  but Ada lists 500 entries only
* SBCL is 2x faster than picoLisp, but ClozureCL/ECL is slower, which 
  is surprising (picoLisp is a pure interpreted LISP, ClozureCL/ECL is compiled)
* if I type 60x more characters than the K version, then I can get 10x 
  speedup with C
* GPCP Component Pascal compiles to the JVM, but it uses a custom hash table
  and buffered output, so it is 2x faster than the optimized Java version
* if the output is not buffered, it takes a significant time to produce the
  results
* READ-LINE on standard input is usually slow in LISP

## Results

| Language   | Chars | Elapsed time |
| ---------- | ----- | ------------ |
| K          |    74 |        2960  |
| Shell      |    84 |       10970  |
| AWK        |   141 |        1830  |
| Python3 (Norwig) |   275 |        4550  |
| picoLisp   |   423 |        6380  |
| REBOL2     |   429 |        6970  |
| Python3    |   464 |        2290  |
| Squeak     |   475 |       11550  |
| SBCL       |  1325 |        2870  |
| ECL        |  1325 |        8970  |
| ClozureCL  |  1325 |        9130  |
| C++        |  2304 |         470  |
| Java       |  2870 |        2120  |
| GForth     |  3003 |        1820  |
| Ada*       |  3203 |        3440  |
| iForth     |  4108 |         450  |
| SwiftForth |  4173 |         550  |
| C          |  4295 |         280  |
| ComponentPascal |  6191 |    750  |


pahihu 4aug2021
