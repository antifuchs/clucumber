Given /^a stub lisp file named \"([^\"]*)\"$/ do |name|
  Given("a file named \"#{name}\" with:", <<-LISP)
(with-open-file (f #p"../files" :direction :output :if-exists :append :if-does-not-exist :create)
  (format f "~A~%" (enough-namestring *load-truename*)))
(with-open-file (f #p"../packages" :direction :output :if-exists :append :if-does-not-exist :create)
  (format f "~A~%" (package-name *package*)))
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

Then /^the packages should be$/ do |expected|
  actual = File.readlines(File.join(working_dir, "packages")).map {|line| [line.strip] }
  expected.diff!(actual)
end

Given /^the standard clucumber setup$/ do
  in_current_dir do
    FileUtils.cp "../clucumber_setup/clucumber_setup.rb", "features/support/"
  end
end
