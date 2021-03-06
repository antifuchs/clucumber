(cl:defpackage #:clucumber-external
  (:export #:start))

(cl:defpackage #:clucumber-steps
  (:export #:define-test-package #:*test-package*
           #:Given* #:When* #:Then*
           #:Before #:After
           #:pending #:fail
           #:var
           #:table-equal)
  (:use #:cl #:cl-interpol))

(cl:defpackage #:clucumber-user
  (:export)
  (:use #:cl #:clucumber-steps))

(cl:defpackage #:clucumber
  (:use #:cl #:clucumber-steps #:clucumber-external #:usocket #:st-json))
