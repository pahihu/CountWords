;;;
;;; CHICKEN Scheme count word frequencies
;;;
;;; csc -O3 -d0 -dynamic count.scm
;;;

(declare
    (fixnum-arithmetic)
    (export count-words) )

(import
   scheme
   chicken.io
   chicken.port
   chicken.sort
   chicken.string )

(require-extension srfi-13)
(require-extension srfi-69)

(define *freq* (make-hash-table string=? string-hash))

(define (process-line line)
   (for-each
      (lambda (word)
         (hash-table-update!/default
            *freq*
            word
            (lambda (x) (+ 1 x))
            0) )
      (string-split (string-downcase! line) ) ) )

(define (count-words file-name)
   (hash-table-clear! *freq*)
   (with-input-from-file file-name
      (lambda ()
         (port-for-each process-line read-line) ) )
   (with-output-to-file "chicken.result"
      (lambda ()
         (for-each
            (lambda (elt)
               (display elt)
               (newline) )
            (sort 
               (hash-table->alist *freq*)
               (lambda (x y)
                  (> (cdr x) (cdr y)) ) ) ) ) ) )
