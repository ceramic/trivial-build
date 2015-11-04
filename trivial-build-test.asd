(defsystem trivial-build-test
  :author "Fernando Borretti <eudoxiahp@gmail.com>"
  :license "MIT"
  :depends-on (:trivial-build
               :fiveam)
  :components ((:module "t"
                :serial t
                :components
                ((:file "trivial-build")))))
