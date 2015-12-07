(in-package :cl-user)
(defpackage trivial-build
  (:use :cl)
  (:export :build))
(in-package :trivial-build)

(defun roswellp ()
  "Are we in a Roswell implementation?"
  (find ".roswell"
        (pathname-directory (trivial-exe:executable-pathname))
        :test #'string=))

(defun load-and-build-code (system-name entry-point binary-pathname)
  "Return a list of code strings to eval."
  (list
   "(setf *debugger-hook* #'(lambda (c h) (declare (ignore h)) (uiop:print-condition-backtrace c) (uiop:quit -1)))"
   (format nil "(asdf:load-system :~A)" system-name)
   (format nil "(setf uiop:*image-entry-point* #'(lambda () ~A))"
           entry-point)
   (format nil "(uiop:dump-image ~S :executable t
  #+sb-core-compression :compression #+sb-core-compression t)"
           binary-pathname)))

(defun code-list-to-eval (eval-flag list)
  (with-output-to-string (stream)
    (loop for code in list do
      (format stream " ~A ~S" eval-flag code))))

(defun boot-and-build (system-name entry-point binary-pathname
                       impl-path impl-flags load-flag eval-flag)
  (let ((command (format nil "~S ~{~A ~} ~A ~S ~A"
                         (namestring impl-path)
                         impl-flags
                         #+quicklisp
                         load-flag
                         #-quicklisp
                         ""
                         #+quicklisp
                         (namestring (merge-pathnames #p"setup.lisp"
                                                      ql:*quicklisp-home*))
                         #-quicklisp
                         ""
                         (code-list-to-eval
                          eval-flag
                          (load-and-build-code system-name entry-point binary-pathname)))))
    (format t "~&Launch: ~A~%" command)
    (terpri)
    (uiop:run-program command
                      :output *standard-output*
                      :error :output)))

(defun build (system-name entry-point binary-pathname)
  "Build the system."
  (declare (type keyword system-name)
           (type string entry-point)
           (type pathname binary-pathname))
  (let ((implementation (lisp-invocation:get-lisp-implementation)))
    (if (roswellp)
        (boot-and-build system-name
                        entry-point
                        binary-pathname
                        "ros"
                        '()
                        "-l"
                        "-e")
        (boot-and-build system-name
                        entry-point
                        binary-pathname
                        (trivial-exe:executable-pathname)
                        (lisp-invocation:lisp-implementation-flags
                         implementation)
                        (lisp-invocation:lisp-implementation-load-flag
                         implementation)
                        (lisp-invocation:lisp-implementation-eval-flag
                         implementation))))
  binary-pathname)
