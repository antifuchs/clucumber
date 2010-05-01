# Taken from cucumber's step definitions

Given /^I am in (.*)$/ do |relative_path|
  @current_dir = self_test_dir(relative_path)
end

Given /^a standard Cucumber project directory structure$/ do
  @current_dir = working_dir
  in_current_dir do
    FileUtils.rm_rf 'features' if File.directory?('features')
    FileUtils.mkdir_p 'features/support'
    FileUtils.mkdir 'features/step_definitions'
  end
end

Given /^a file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

When /^I run cucumber (.*)$/ do |cucumber_opts|
  run "#{Cucumber::RUBY_BINARY} -r rubygems #{Cucumber::BINARY} --no-color #{cucumber_opts} CUCUMBER_OUTPUT_ENCODING=UTF-8"
end

Then /^it should (fail|pass)$/ do |success|
  if success == 'fail'
    last_exit_status.should_not == 0
  else
    if last_exit_status != 0
      raise "Failed with exit status #{last_exit_status}\nSTDOUT:\n#{last_stdout}\nSTDERR:\n#{last_stderr}"
    end
  end
end

Then /^it should (fail|pass) with$/ do |success, output|
  last_stdout.should == output
  Then("it should #{success}")
end

Then /^the output should contain$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should not contain$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should be$/ do |text|
  last_stdout.should == text
end

Then /^print output$/ do
  puts last_stdout
end
