Given /^a stub lisp file named \"([^\"]*)\"$/ do |name|
  Given("a file named \"#{name}\" with:", <<-LISP)
(with-open-file (f #p"../files" :direction :output :if-exists :append :if-does-not-exist :create)
  (format f "~A~%" (enough-namestring *load-truename*)))
LISP
end

When /^I start clucumber on port (\d+)$/ do |port|
  @clucumber = ClucumberSubprocess.new(File.join(working_dir, 'features'), :port => port)
  @clucumber.start
end

Then /^show me the clucumber output$/ do
  puts @clucumber.output
end

After do
  @clucumber.kill if @clucumber
end

Then /^files should be loaded in this order:$/ do |expected|
  actual = File.readlines(File.join(working_dir, "files")).map {|line| [line.strip] }
  expected.diff!(actual)
end
