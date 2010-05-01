(Given* #?"^I have a clucumber variable \"([^\"]*)\" set to \"([^\"]*)\"$" (variable-name value)
  (setf (var (intern variable-name :keyword)) value))

(Then* #?"^clucumber variable \"([^\"]*)\" should have value \"([^\"]*)\"$" (variable-name value)
  (assert (string= (var (intern variable-name :keyword)) value)))

(Then* #?"^clucumber variable \"([^\"]*)\" should be undefined$" (variable-name)
  (assert (eql (nth-value 1 (var (intern variable-name :keyword))) nil)))

(When* #?/^I reset the variable state$/ ()
  (clucumber::reset-state))
