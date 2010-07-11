(cl:defpackage #:clucumber-bootstrap
  (:use #:cl))

(cl:in-package #:clucumber-bootstrap)

(defparameter *my-name* *load-truename*)
(defparameter *vendor-dirs*
              (mapcar
               (lambda (potential-dir)
                 (let ((name (pathname-name potential-dir)))
                   (if (and name (not (eql name :unspecific)))
                       (make-pathname :directory `(,@(pathname-directory potential-dir)
                                                     ,name))
                       potential-dir)))
               (directory (merge-pathnames (make-pathname :directory `(,@(pathname-directory *my-name*)
                                                                         "vendor")
                                                          :name :wild)))))

(defun vendor-dir-to-system-name (dir)
  (car (last (pathname-directory dir))))

(require :asdf)

(loop for vendor-dir in *vendor-dirs*
      for system-name = (vendor-dir-to-system-name vendor-dir)
      unless (asdf:find-system system-name nil)
        do (format *trace-output* ";; Loading bundled ~A~%" system-name)
        and do (load (merge-pathnames (make-pathname :name system-name
                                                     :type "asd")
                           vendor-dir)))

(load (merge-pathnames #p"clucumber.asd" *load-truename*))
