(cl:in-package #:clucumber)

(defvar *base-pathname*)

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
        (mapc #'load (sort files #'string<
                           :key (lambda (path)
                                  (enough-namestring path base-pathname))))))))

(defun serve-cucumber-requests (socket &aux (stream (socket-stream socket)))
  (handler-case
      (loop
        (let* ((line (read-line stream))
               (message (read-json line nil))
               (reply (call-wire-protocol-method message)))
          (st-json:write-json reply stream)
          (terpri stream)
          (finish-output stream)))
    (end-of-file nil nil)))


;;; Step definitions


(defparameter *steps* (make-array 0 :adjustable t :fill-pointer t))

(defclass step-definition ()
     ((regex :initarg :regex :accessor regex)
      (cont :initarg :continuation :accessor continuation)
      (scanner :accessor scanner)
      (definition-file :initform *load-truename* :accessor definition-file)))

(defmethod initialize-instance :after ((o step-definition) &key regex &allow-other-keys)
  (setf (scanner o) (cl-ppcre:create-scanner regex)))

(defun add-step (regex function)
  (let ((existing-step (find regex *steps* :key #'regex :test #'string=)))
    (if existing-step
        (setf (continuation existing-step) function
              (definition-file existing-step) *load-truename*)
        (vector-push-extend
         (make-instance 'step-definition :regex regex :continuation function)
         *steps*)))
  *steps*)

(defmacro clucumber-steps:Given* (regex args &body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (add-step ,regex (lambda (,@args) ,@body))))

(defmacro clucumber-steps:Then* (regex args &body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (add-step ,regex (lambda (,@args) ,@body))))

(defmacro clucumber-steps:When* (regex args &body body)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (add-step ,regex (lambda (,@args) ,@body))))

;;; Packages

(defun clucumber-external:start (*base-pathname* host port &key quit)
  (setf (fill-pointer *steps*) 0)
  (load-definitions *base-pathname*)
  (let ((server (usocket:socket-listen host port :reuse-address t)))
    (unwind-protect
        (loop
          (let ((socket (usocket:socket-accept server :element-type 'character)))
            (serve-cucumber-requests socket))
          (when quit (return)))
      (usocket:socket-close server))))

(defvar clucumber-steps:*test-package* (find-package :clucumber-user))

(defmacro clucumber-steps:define-test-package (name &rest defpackage-arguments)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defpackage ,name
       (:use #:clucumber)
       ,@defpackage-arguments)
     (setf *test-package* (find-package ',name))))

;;; Before / after hooks:

;; I'm not sure if these can handle tags. It would certainly be nice if they could.

(defvar *before-hooks* (make-array 0 :adjustable t :fill-pointer t))
(defvar *after-hooks* (make-array 0 :adjustable t :fill-pointer t))

(defmacro clucumber-steps:Before (&body body)
  `(vector-push-extend (lambda () ,@body) *before-hooks*))

(defmacro clucumber-steps:After (&body body)
  `(vector-push-extend (lambda () ,@body) *before-hooks*))

;;; Wire protocol

(defvar *wire-protocol-methods* (make-hash-table :test #'equal))

(defmacro define-wire-protocol-method (name args &body body)
  (let ((params (gensym)))
    `(setf (gethash ,name *wire-protocol-methods*)
           (lambda (,params)
             (declare (ignorable ,params))
             (catch 'wire-protocol-method
               (let (,@(mapcar (lambda (arg-spec)
                                 (destructuring-bind (arg-name &optional
                                                               (jso-name (string-downcase arg-name)))
                                     (if (listp arg-spec) arg-spec (list arg-spec))
                                   `(,arg-name (getjso ,jso-name ,params))))
                         args))
                 ,@body))))))

(defun call-wire-protocol-method (wire-protocol-message)
  (let ((method (gethash (first wire-protocol-message) *wire-protocol-methods*)))
    (if method
        (funcall method
                 (second wire-protocol-message))
        (list "fail"))))

(defun clucumber-steps:fail (message &key format-args exception backtrace)
  (throw 'wire-protocol-method
    (list "fail"
          (apply #'jso
                 `("message" ,(apply #'format nil message format-args)
                             ,@(when exception
                                 `("exception" ,exception))
                             ,@(when backtrace
                                 `("backtrace" ,backtrace)))))))

(defun clucumber-steps:pending (&optional message)
  (throw 'wire-protocol-method
    `("pending" ,@(when message
                    (list message)))))

(defmacro with-error-handling (&body body)
  `(let ((*debugger-hook* (lambda (condition prev-hook)
                            (declare (ignore prev-hook))
                            (fail "Non-error condition invoked the debugger"
                                  :exception (prin1-to-string condition)
                                  :backtrace (trivial-backtrace:print-backtrace condition :output nil)))))
     (handler-case
               (progn ,@body)
             (error (condition)
               (fail "Caught an error"
                     :exception (prin1-to-string condition)
                     :backtrace (trivial-backtrace:print-backtrace condition :output nil))))))

(define-wire-protocol-method "begin_scenario" ()
  (with-error-handling
    (map nil 'funcall *before-hooks*)
    (list "success")))

(define-wire-protocol-method "end_scenario" ()
  (with-error-handling
    (map nil 'funcall *after-hooks*)
    (reset-state)
    (list "success")))

(define-wire-protocol-method "step_matches" ((name-to-match "name_to_match"))
  (list "success"
        (loop for posn from 0
              for step across *steps*
              for scanner = (scanner step)
              for (matchp end starts ends) = (multiple-value-list (cl-ppcre:scan scanner name-to-match))
              for arguments = (map 'list (lambda (start end)
                                           (jso "val" (subseq name-to-match start end)
                                                "pos" start))
                                   starts ends)
              if matchp collect (jso "id" posn "args" arguments
                                     "regexp" (regex step)
                                     "source" (enough-namestring (definition-file step)
                                                     *base-pathname*)))))

(define-wire-protocol-method "invoke" (id args)
  (let ((step (elt *steps* id)))
    (if step
        (with-error-handling
          (apply (continuation step) args)
          (list "success"))
        (fail "Step ~S is undefined" :format-args `(,id)))))

(define-wire-protocol-method "snippet_text" ((keyword "step_keyword") (step-name "step_name"))
  ;; TODO: figure out multiline_arg_class
  (list "success"
        (format nil "(~A* #?/^~A$/ ()~%  (pending))" keyword step-name)))

;;; Sharing state between steps:

(defvar *variables* (make-hash-table :test #'eql))

(defun clucumber-steps:var (name &optional default)
  (gethash name *variables* default))

(defun (setf clucumber-steps:var) (new-val name &optional default)
  (setf (gethash name *variables* default) new-val))

(defun reset-state ()
  (clrhash *variables*))
