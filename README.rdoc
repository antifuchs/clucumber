Clucumber, the CL Cucumber adapter
==================================

This is a (somewhat complete) implementation of the [cucumber wire
protocol](http://wiki.github.com/aslakhellesoy/cucumber/wire-protocol) in (as portable as possible) Common Lisp. This means you can
write [cucumber](http://cukes.info/) features, and write lisp code to execute
your steps.

Getting started
---------------

First, you write your cucumber features like you would any other.

Then you define cucumber steps in CL: Just place them in
features/step_definitions/*.lisp.

If your application needs any support code, place that in
support/*.lisp.

Files in support and step_definitions/ are loaded (not file-compiled)
in alphabetical order, with support/ files being loaded before step
definitions.

Running tests
-------------

In your `features/support/env.rb`, you load the clucumber.rb included in this distribution. Then, you run something like this:

	begin
	  @main_clucumber = ClucumberSubprocess.new(File.expand_path("../", File.dirname(__FILE__)),
	                                           :port => 42428)
	  at_exit do
	    @main_clucumber.kill
	  end

	  @main_clucumber.start <<-LISP
		;; Put code here that loads your application.
	  LISP
	rescue PTY::ChildExited
	  puts(@main_clucumber && @main_clucumber.output)
	end

This will launch a lisp with clucumber loaded (pass :lisp parameter to `ClucumberSubprocess.new` to specify which lisp, it defaults to sbcl), and start listening on port 42428.

Then, on the command line, you run cucumber:

        $ cucumber

And you watch the lines zip by.

That should be all (-:

Over the next few days, I hope to fill out the test suite with more
interesting examples that you can use as a reference.
