(compile-file "simple.lisp" :system-p t)
(c:build-program "ecl_simple" :lisp-files '("simple.o"))
(quit)
