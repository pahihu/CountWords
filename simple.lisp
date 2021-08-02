(declaim
   (inline split-string) )


;; modified from http://rosettacode.org/wiki/Tokenize_a_string#Common_Lisp
(defun split-string (string)
  (declare (type simple-string string))
  (declare (optimize (speed 3) (safety 1) (debug 0)))
  (loop for start = 0 then (1+ finish)
        for finish = (position #\Space string :start start)
        collecting (subseq string start finish)
        until (null finish)))

(defparameter *counter* (make-hash-table :test #'equal))

(defun trim-spaces (string)
  (string-trim '(#\Space #\Tab #\Newline) string))

(defun update-word (word)
  (declare (optimize (speed 3) (safety 1) (debug 0))) 
  (incf (gethash word *counter* 0)))

(defun command-line-args ()
#+clozure *command-line-argument-list*
#+ecl     (ext:command-args)
#+sbcl    sb-ext:*posix-argv*
  )

(defun process-file (in-file-name &key (output t))
  (with-open-file (in-stream in-file-name)
     (loop for line = (read-line in-stream nil) while line
           for words = (split-string (nstring-downcase (trim-spaces line)))
           do (loop for word in words unless (zerop (length word))
                    do (update-word word))))
  (let ((ordered (loop for key being the hash-keys of *counter*
                       using (hash-value value)
                       collect (cons key value))))
    (setf ordered (sort ordered #'> :key #'cdr))
    (dolist (pair ordered)
       (format output "~a ~a~%" (car pair) (cdr pair)))))

(defun main ()
   (process-file (second (command-line-args))) 
   (quit) )

(defun bench ()
   (with-open-file (out-stream "lisp.result" :direction :output :if-exists :supersede)
      (process-file "kjvbible_x10.txt" :output out-stream) ) )

#+ecl (main)
