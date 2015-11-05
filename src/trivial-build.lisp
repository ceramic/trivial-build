(in-package :cl-user)
(defpackage trivial-build
  (:use :cl)
  (:export :build))
(in-package :trivial-build)

(defun pre-code ()
  (list
   "(setf *debugger-hook*
          #'(lambda (c h)
              (declare (ignore h))
              (uiop:print-condition-backtrace c)
              (uiop:quit -1)))"))

(defun load-and-build-code (system-name entry-point binary-pathname)
  (list
   (format nil "(ql:quickload :~A)" system-name)
   (format nil "(setf uiop:*image-entry-point* #'(lambda () ~A))"
           entry-point)
   (format nil "(uiop:dump-image ~S :executable t
  #+sb-core-compression :compression #+sb-core-compression t)"
           binary-pathname)))

(defun code-list-to-eval (implementation list)
  (with-output-to-string (stream)
    (loop for code in list do
         (format stream " ~A ~S"
                 (lisp-invocation:lisp-implementation-eval-flag implementation)
                 code))))

(defun build (system-name entry-point binary-pathname)
  "Build the system."
  (declare (type keyword system-name)
           (type string entry-point)
           (type pathname binary-pathname))
  (let* ((impl-pathname (trivial-exe:executable-pathname))
         (implementation (lisp-invocation:get-lisp-implementation))
         (ql-setup (merge-pathnames #p"setup.lisp" ql:*quicklisp-home*))
         (command (format nil "~S ~A ~A ~S ~A"
                          (namestring impl-pathname)
                          (code-list-to-eval
                           implementation
                           (pre-code))
                          (lisp-invocation:lisp-implementation-load-flag implementation)
                          (namestring ql-setup)
                          (code-list-to-eval
                           implementation
                           (load-and-build-code system-name entry-point binary-pathname)))))
      (format t "~&Launch: ~A~%" command)
      (terpri)
      (uiop:run-program command
                        :output *standard-output*
                        :error :output))
  binary-pathname)
