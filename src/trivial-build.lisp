(in-package :cl-user)
(defpackage trivial-build
  (:use :cl)
  (:export :build))
(in-package :trivial-build)

(defun extra-flags (system-name entry-point binary-pathnam)
  (concatenate 'string
               #+sbcl
               (format nil "--core ~S" sb-int:*core-string*)))

(defun load-and-build-code (system-name entry-point binary-pathname)
  (list
   "(setf *debugger-hook* #'(lambda (c h) (declare (ignore h)) (uiop:print-condition-backtrace c) (uiop:quit -1)))"
   (format nil "(asdf:load-system :~A)" system-name)
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
         (command (format nil "~S ~A ~{~A ~} ~A ~S ~A"
                          (namestring impl-pathname)
                          (extra-flags system-name entry-point binary-pathname)
                          (lisp-invocation:lisp-implementation-flags
                           implementation)
                          (lisp-invocation:lisp-implementation-load-flag implementation)
                          (namestring (merge-pathnames #p"setup.lisp"
                                                       ql:*quicklisp-home*))
                          (code-list-to-eval
                           implementation
                           (load-and-build-code system-name entry-point binary-pathname)))))
      (format t "~&Launch: ~A~%" command)
      (terpri)
      (uiop:run-program command
                        :output *standard-output*
                        :error :output))
  binary-pathname)
