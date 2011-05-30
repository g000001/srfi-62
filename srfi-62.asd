;;;; srfi-62.asd

(cl:in-package :asdf)

(defsystem :srfi-62
  :serial t
  :components ((:file "package")
               (:file "srfi-62")))

(defmethod perform ((o test-op) (c (eql (find-system :srfi-62))))
  (load-system :srfi-62)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :srfi-62-internal :srfi-62))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

