(asdf:defsystem clucumber
  :depends-on (:cl-interpol :cl-ppcre :trivial-backtrace :usocket :st-json)
  :serial t
  :components ((:file "packages")
               (:file "server")))
