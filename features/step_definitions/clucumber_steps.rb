Given /^a stub lisp file named \"([^\"]*)\"$/ do |name|
  Given("a file named \"#{name}\" with:", <<-LISP)
(with-open-file (f #p"../files" :direction :output :if-exists :append :if-does-not-exist :create)
  (format f "~A~%" (enough-namestring *load-truename*)))
(with-open-file (f #p"../packages" :direction :output :if-exists :append :if-does-not-exist :create)
  (format f "~A~%" (package-name *package*)))
LISP
end

When /^I start clucumber on port (\d+)$/ do |port|
  @clucumber = ClucumberSubprocess.launch(File.join(current_dir, 'features'), :port => port)
  @clucumber.listen
end

Then /^show me the clucumber output$/ do
  puts @clucumber.output
end

After do
  @clucumber.kill if @clucumber
end

Then /^files should be loaded in this order:$/ do |expected|
  actual = File.readlines(File.join(current_dir, "files")).map {|line| [line.strip] }
  expected.diff!(actual)
end

Then /^the packages should be$/ do |expected|
  actual = File.readlines(File.join(current_dir, "packages")).map {|line| [line.strip] }
  expected.diff!(actual)
end

Given /^the standard clucumber setup$/ do
  FileUtils.cp(File.expand_path(File.join("..", "..", "self_test", "clucumber_setup.rb"),
                                File.dirname(__FILE__)),
               File.join(current_dir, "features/support/"))
  FileUtils.cp(File.expand_path(File.join("..", "..", "examples", "clucumber.wire"),
                                File.dirname(__FILE__)),
               File.join(current_dir, "features/step_definitions/"))
end
