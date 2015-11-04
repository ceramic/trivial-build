(defsystem trivial-build
  :author "Fernando Borretti <eudoxiahp@gmail.com>"
  :maintainer "Fernando Borretti <eudoxiahp@gmail.com>"
  :license "MIT"
  :version "0.1"
  :homepage ""
  :bug-tracker ""
  :source-control (:git "")
  :depends-on (:trivial-exe
               :lisp-invocation)
  :components ((:module "src"
                :serial t
                :components
                ((:file "trivial-build"))))
  :description "Compile a system into an executable."
  :long-description
  #.(uiop:read-file-string
     (uiop:subpathname *load-pathname* "README.md"))
  :in-order-to ((test-op (test-op trivial-build-test))))
