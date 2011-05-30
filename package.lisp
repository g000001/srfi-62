;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :srfi-62
  (:export :enable-s-expression-comments
           :disable-s-expression-comments))

(defpackage :srfi-62-internal
  (:use :srfi-62 :cl :fiveam))

