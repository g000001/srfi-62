;;;; srfi-62.asd

(cl:in-package :asdf)


(defsystem :srfi-62
  :version "20200201"
  :description "SRFI 62: S-expression comments"
  :long-description "SRFI 62: S-expression comments
https://srfi.schemers.org/srfi-62"
  :author "CHIBA Masaomi"
  :maintainer "CHIBA Masaomi"
  :license "Unlicense"
  :serial t
  :depends-on (:fiveam)
  :components ((:file "package")
               (:file "srfi-62")))


(defmethod perform :after ((o load-op) (c (eql (find-system :srfi-62))))
  (let ((name "https://github.com/g000001/srfi-62")
        (nickname :srfi-62))
    (if (and (find-package nickname)
             (not (eq (find-package nickname)
                      (find-package name))))
        (warn "~A: A package with name ~A already exists." name nickname)
        (rename-package name name `(,nickname)))))


(defmethod perform ((o test-op) (c (eql (find-system :srfi-62))))
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let* ((pkg "https://github.com/g000001/srfi-62#internals")
               (result (funcall (_ :fiveam :run) (_ pkg :srfi-62))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
