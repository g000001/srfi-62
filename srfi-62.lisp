;;;; srfi-62.lisp

(cl:in-package "https://github.com/g000001/srfi-62#internals")


(def-suite srfi-62)


(in-suite srfi-62)


(defun s-expression-comments (stream char arg)
  (declare (ignore char))
  (dotimes (i (or arg 1))
    (read stream 'T () 'T))
  (values))


(defun unset-dispatch-macro-character (disp-char sub-char &optional (rt *readtable*))
    #+(or :sbcl :lispworks)
    (set-dispatch-macro-character disp-char sub-char nil rt))


(defun enable-s-expression-comments (&optional (rt *readtable*))
    (set-dispatch-macro-character #\# #\;
                                  #'s-expression-comments
                                  rt)
    (values))


(defun disable-s-expression-comments (&optional (rt *readtable*))
    (let ((fctn (get-dispatch-macro-character #\# #\; rt)))
      (when (and fctn
                 (eq #'s-expression-comments
                     (coerce fctn 'function)))
        (unset-dispatch-macro-character #\# #\; rt)))
    (values))


(test s-expression-comments
  (let ((*readtable* (copy-readtable nil)))
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
  (let ((*readtable* (copy-readtable nil)))
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
    (disable-s-expression-comments)
    (signals (error)
      (eval (read-from-string "(#;a #;b #;c)")))
    ))


;;; *EOF*


