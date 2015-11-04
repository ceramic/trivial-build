(in-package :cl-user)
(defpackage trivial-build
  (:use :cl)
  (:export :build))
(in-package :trivial-build)

(defun load-and-build-code (system-name entry-point binary-pathname)
  (list
   (format nil "(ql:quickload :~A)" system-name)
   (format nil "(setf uiop:*image-entry-point* #'(lambda () ~A))"
           entry-point)
   (format nil "(uiop:dump-image ~S :executable t
  #+sb-core-compression :compression #+sb-core-compression t)"
           binary-pathname)))

(defun build (system-name entry-point binary-pathname)
  "Build the system."
  (declare (type keyword system-name)
           (type string entry-point)
           (type pathname binary-pathname))
  (let ((impl-pathname (trivial-exe:executable-pathname))
        (implementation (lisp-invocation:get-lisp-implementation)))
    (let* ((args (with-output-to-string (stream)
                   (loop for arg in (load-and-build-code system-name
                                                         entry-point
                                                         binary-pathname)
                         do
                     (format stream " ~A ~S"
                             (lisp-invocation:lisp-implementation-eval-flag implementation)
                             arg))))
           (command (format nil "~S ~A" (namestring impl-pathname) args)))
      (format t "~&Launch: ~A~%" command)
      (terpri)
      (uiop:run-program command
                        :output *standard-output*
                        :error :output)))
  binary-pathname)
