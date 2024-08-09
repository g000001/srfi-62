;;;; package.lisp

(cl:in-package :cl-user)

(defpackage "https://github.com/g000001/srfi-62"
  (:export :enable-s-expression-comments
           :disable-s-expression-comments
           :s-expression-comments))

(defpackage "https://github.com/g000001/srfi-62#internals"
  (:use "https://github.com/g000001/srfi-62"
        cl
        fiveam))

