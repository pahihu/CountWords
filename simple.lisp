(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0)))

;; modified from http://rosettacode.org/wiki/Tokenize_a_string#Common_Lisp
(defun split-string (string)
  (loop for start = 0 then (1+ finish)
        for finish = (position #\Space string :start start)
        collecting (subseq string start finish)
        until (null finish)))

(defparameter *counter* (make-hash-table :test #'equal))

(defun trim-spaces (string)
  (string-trim '(#\Space #\Tab #\Newline) string))

(defun update-word (word) 
  (incf (gethash word *counter* 0)))

(defun command-line-args ()
#+clozure *command-line-argument-list*
#+ecl     (ext:command-args)
#+sbcl    sb-ext:*posix-argv*
  )

(defun main ()
  (with-open-file (stream (second (command-line-args)))
     (loop for line = (read-line stream nil) while line
           for words = (split-string (string-downcase (trim-spaces line)))
           do (loop for word in words unless (zerop (length word))
                    do (update-word word))))
  (let ((ordered (loop for key being the hash-keys of *counter*
                       using (hash-value value)
                       collect (cons key value))))
    (setf ordered (sort ordered #'> :key #'cdr))
    (dolist (pair ordered)
      (format t "~a ~a~%" (car pair) (cdr pair))))
    (quit)
  )

#+ecl (main)
#+ecl (quit)
