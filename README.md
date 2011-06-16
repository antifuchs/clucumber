Clucumber, the CL Cucumber adapter
==================================

This is a (somewhat complete) implementation of the [cucumber wire
protocol](http://wiki.github.com/aslakhellesoy/cucumber/wire-protocol) in (as portable as possible) Common Lisp. This means you can
write [cucumber](http://cukes.info/) features, and write lisp code to execute
your steps.

Using clucumber
---------------

First, install the clucumber gem via rubygems:

	gem install clucumber

On the lisp side, clucumber depends on cl-interpol, cl-ppcre, trivial-backtrace, usocket and st-json. All of these are available in [quicklisp](http://quicklisp.org), and I recommend you use this to manage your lisp libraries.

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

Put a .wire file into your step_definitions dir; I like to name it `features/step_definitions/clucumber.wire`. See [examples/clucumber.wire](//github.com/antifuchs/clucumber/tree/master/examples/clucumber.wire) for one that works for me.

In your `features/support/env.rb`, you use something like this:

	require 'clucumber'
	begin
	  ClucumberSubprocess.launch(File.expand_path("../", File.dirname(__FILE__))).listen <<-LISP
            ;; Put code here that loads your application.
	  LISP
	rescue PTY::ChildExited
	  STDERR.puts(@main_clucumber && @main_clucumber.output)
	end

This will launch a lisp with clucumber loaded (pass :lisp parameter to `ClucumberSubprocess.new` to specify which lisp, it defaults to sbcl), and (if you used the [examples/clucumber.wire](//github.com/antifuchs/clucumber/tree/master/examples/clucumber.wire) file) start listening on port 42428.

Then, on the command line, you run cucumber:

        $ cucumber

And you watch the green or yellow lines zip by.

To see an example of a test suite that uses clucumber, see  [the features directory in  cl-beanstalk](http://github.com/antifuchs/cl-beanstalk/tree/master/features/). It comes with steps defined in ruby and Common Lisp.
