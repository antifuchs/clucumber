(cl:in-package #:clucumber)

(defun load-definitions (base-pathname)
  (let ((support-files (directory (merge-pathnames (make-pathname :directory '(:relative "support"
                                                                               :wild-inferiors)
                                                                  :name :wild
                                                                  :type "lisp")
                                                   base-pathname)))
        (step-files (directory (merge-pathnames (make-pathname :directory '(:relative "step_definitions"
                                                                            :wild-inferiors)
                                                               :name :wild
                                                               :type "lisp")
                                                base-pathname))))
    (dolist (files (list support-files step-files))
      (let ((*readtable* (copy-readtable))
            (*package* *test-package*))
        (cl-interpol:enable-interpol-syntax)
        (mapc #'load (sort files #'string>
                           :key (lambda (path)
                                  (enough-namestring path base-pathname))))))))

(defun serve-cucumber-requests (socket)
  (let ((stream (usocket:socket-stream socket)))
   (unwind-protect
       (loop with eof-value = (gensym)
             for line = (read-line stream nil eof-value)
             until (eql line eof-value)
             do (catch 'exited
                  (let ((did-not-unwind nil)
                        (*debugger-hook* (lambda (condition prev-hook)
                                           (declare (ignore prev-hook))
                                           (print :debugger stream)
                                           (prin1 (trivial-backtrace:print-backtrace condition
                                                                                     :output nil))
                                           (throw 'exited nil))))
                    (unwind-protect 
                        (progn
                          (call-step line)
                          (print :ok stream)
                          (setf did-not-unwind t))
                      (unless did-not-unwind
                        (print :unwind stream)
                        (terpri stream)))))))))

;;; Step definitions


(defparameter *steps* ())

(defun call-step (line)
  (let ((matches (remove-if-not (lambda (regexp)
                                  (cl-ppcre:scan regexp line))
                                *steps* :key #'car)))
    (unless (= 1 (length matches))
      (error "Ambiguous step definitions matching ~S: ~S" line matches))
    (let ((regex (car (first matches)))
          (function (cdr (first matches))))
      (apply function (coerce (nth-value 1 (cl-ppcre:scan-to-strings regex line)) 'list)))))

(defun add-step (regex function)
  (let ((existing-step (find regex *steps* :key #'car :test #'string=)))
    (if existing-step
        (setf (cdr existing-step) function)
        (setf *steps* (nconc *steps*
                             (list (cons regex function))))))
  *steps*)

(defmacro Given (regex args &body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (add-step ,regex (lambda (,@args) ,@body))))

(defmacro Then (regex args &body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (add-step ,regex (lambda (,@args) ,@body))))

;;; TODO: Given, When, Then.

;;; Packages

(defun clucumber-external:start (base-pathname host port)
  (load-definitions base-pathname)
  (let ((socket (usocket:socket-connect host port)))
    (serve-cucumber-requests socket)))

(defvar clucumber-steps:*test-package* (find-package :clucumber-user))

(defmacro clucumber-steps:define-test-package (name &rest defpackage-arguments)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defpackage ,name
       (:use #:clucumber)
       ,@defpackage-arguments)
     (setf *test-package* (find-package ',name))))
