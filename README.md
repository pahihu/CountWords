Count words
===========

On comp.lang.forth Ben Hoyt posted a problem of counting word frequencies.
His conclusions can be found at [Performance comparisons](https://benhoyt.com/writings/count-words).

The picoLisp and Ada entry is a modified version of a [Rosetta-code problem](http://rosettacode.org/wiki/Word_frequency).

My conclusions:

* the fastest is the optimized C, which is 6x faster than the AWK entry
* if I type 60x more characters than the K version, then I can get 10x 
  speedup with C
* compiled SBCL is 2x faster than interpreted picoLisp
* if we compare the simple solutions, C++ is the slowest


## Comparison

| Time  | Language |
| ----- | -------- |
|  1.8  | AWK      |
|  2.9  | SBCL	   |
|  3.0  | K        |
|  4.6  | Python   |
|  6.4  | picoLisp |
|  7.0  | REBOL2   |
|  8.6  | CHICKEN  |
|  9.7  | Squeak   |
| 10.2  | C++      |


## Results

| Language   | Chars | Elapsed time |
| ---------- | ----- | ------------ |
| K          |    74 |         3.0  |
| Shell      |    84 |        11.0  |
| AWK        |   141 |         1.8  |
| Python3 (Norwig) | 275 |     4.6  |
| picoLisp   |   373 |         6.4  |
| REBOL2     |   429 |         7.0  |
| Python3    |   464 |         2.3  |
| Squeak     |   475 |         9.7  |
| CHICKEN    |  1120 |         8.6  |
| SBCL       |  1325 |         2.9  |
| ECL        |  1325 |         9.0  |
| ClozureCL  |  1325 |         9.1  |
| C++        |  2304 |         0.5  |
| C++ (simple) | 812 |	      10.2  |
| Java       |  2870 |         2.1  |
| GForth     |  3003 |         1.8  |
| iForth     |  4108 |         0.5  |
| SwiftForth |  4173 |         0.6  |
| C          |  4295 |         0.3  |
| ComponentPascal |  6191 |    0.8  |


pahihu 6aug2021
