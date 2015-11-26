(in-package :cl-user)
(defpackage trivial-build-test
  (:use :cl :fiveam)
  (:export :main
           :run-tests))
(in-package :trivial-build-test)

(defun main ()
  (format t "1"))

(def-suite tests
  :description "trivial-build tests.")
(in-suite tests)

(test simple-test
  (finishes (main))
  (let ((path (asdf:system-relative-pathname :trivial-build #p"t/binary")))
    (finishes
     (trivial-build:build :trivial-build-test "(trivial-build-test:main)" path))
    (is-true
     (probe-file path))
    (is
     (equal (string-trim (list #\Newline)
                         (uiop:run-program (namestring path) :output :string))
            "1"))
    (when (probe-file path)
      (delete-file path))))

(defun run-tests ()
  (run! 'tests))
