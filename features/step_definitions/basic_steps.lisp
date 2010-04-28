(Given* #?"^I start clucumber in (.*)$" (path)
   (assert path))

(When* #?"^I define some-other-package as the test package$" ()
  (pending))

(Then* #?"^the current package should be \"([^\"]+)\"$" (package-name)
  (pending (format nil "package is ~A" package-name)))
