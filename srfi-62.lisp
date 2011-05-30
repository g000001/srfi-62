;;;; srfi-62.lisp

(cl:in-package :srfi-62-internal)

(def-suite srfi-62)

(in-suite srfi-62)

(defvar *original-readtable* nil)

(defvar *restore-s-expression-comments* nil)

(defun s-expression-comments (stream char arg)
  (declare (ignore char))
  (dotimes (i (or arg 1))
    (read stream 'T () 'T))
  (values))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %enable-s-expression-comments ()
    (unless *original-readtable*
      (setf *original-readtable* *readtable*
            *readtable* (copy-readtable))
      (set-dispatch-macro-character #\# #\;
                                    #'s-expression-comments))
    (values))

  (defun %disable-s-expression-comments ()
    (when *original-readtable*
      (setf *readtable* *original-readtable*
            *original-readtable* nil))
    (values)) )

(defmacro enable-s-expression-comments ()
  '(eval-when (:compile-toplevel :load-toplevel :execute)
    (setf *restore-s-expression-comments* 'T)
    (%enable-s-expression-comments)))

(defmacro disable-s-expression-comments ()
  '(eval-when (:compile-toplevel :load-toplevel :execute)
    (setf *restore-s-expression-comments* nil)
    (%disable-s-expression-comments)))

(test s-expression-comments
  (let ((*original-readtable* nil)
        (*restore-s-expression-comments* nil)
        (*readtable* (copy-readtable nil)))
    (enable-s-expression-comments)
    (is (= (eval (read-from-string "(+ 1 #;(* 2 3) 4)"))
           5))
    (is (equal (eval (read-from-string "(list 'x #;'y 'z)"))
               '(x z)) )
    (is (= (eval (read-from-string "(* 3 4 #;(+ 1 2))"))
           12))
    (is (= (eval (read-from-string "(#;sqrt abs -16)"))
           16))
    (is (equal (eval (read-from-string "'(a . #;b c)"))
           (quote (a . c)) ))
    (is (equal (eval (read-from-string "'(a . b #;c)"))
               (quote (a . b)) ))
    (is (equal (eval (read-from-string "'(#2;1 2 #2;3 4)"))
               () ))
    (is (equal (eval (read-from-string "(list 'a #;(list 'b #;c 'd) 'e)"))
               '(a e) ))
    (is (equal (eval (read-from-string "(list 'a #2;(list 'b #2;c 'd) 'e)"))
               '(a) ))))

(test s-expression-comments-error
  (let ((*original-readtable* nil)
        (*restore-s-expression-comments* nil)
        (*readtable* (copy-readtable nil)))
    (enable-s-expression-comments)
    (signals (error)
      (eval (read-from-string "(#;a . b)")))
    (signals (error)
      (eval (read-from-string "(a . #;b)")))
    (signals (error)
      (eval (read-from-string "(a #;. b)")))
    (signals (error)
      (eval (read-from-string "(#;x #;y . z)")))
    (signals (error)
      (eval (read-from-string "(#; #;x #;y . z)")))
    (signals (error)
      (eval (read-from-string "(#; #;x . z)")))
    ))

(test side-effects
  (is-false *original-readtable*)
  (is-false *restore-s-expression-comments*)
  ;;
  (enable-s-expression-comments)
  (disable-s-expression-comments)
  (is-false *original-readtable*)
  (is-false *restore-s-expression-comments*))
