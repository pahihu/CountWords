;;;
;;; CHICKEN Scheme count word frequencies
;;;
;;; csc -O3 -d0 -dynamic count.scm
;;;
(import scheme
        (chicken io)
        (chicken port)
        (chicken sort)
        (chicken string)
        (chicken time) )

(require-extension srfi-128)
(require-extension srfi-113)
(require-extension srfi-13)

(define string-comparator
   (make-comparator string? string=? string<? string-hash) )

(define *freq* (bag string-comparator))

(define (process-line line)
   (for-each
      (lambda (elt)
         (bag-adjoin! *freq* elt) )
      (string-split (string-downcase! line) ) ) )

(define (count-words file-name)
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
               (bag-fold-unique
                  (lambda (value count prev)
                     (cons (cons value count) prev) )
                  '()
                  *freq* )
               (lambda (x y)
                  (> (cdr x) (cdr y)) ) ) ) ) ) )
