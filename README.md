Clucumber, the CL Cucumber adapter
==================================

This is a (somewhat complete) implementation of the [cucumber wire
protocol](http://wiki.github.com/aslakhellesoy/cucumber/wire-protocol) in (as portable as possible) Common Lisp. This means you can
write [cucumber](http://cukes.info/) feature definitions, and write lisp code to execute
your scenarios.

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

This is the hard part, and the part where clucumber needs more
work. First, load your lisp, then load asdf, and clucumber (including
all its dependencies, which you hopefully have installed; you can get
them all from clbuild):

        (require :asdf)
        (asdf:oos 'asdf:load-op :clucumber)

Then, you open a socket for cucumber to connect to (localhost:42424 in this case):

        (clucumber-external:start #p"/path/to/your/features/" "localhost" 42424)

Then you create a features/step_definitions/lisp.wire file:

        host: localhost
        port: 42424

Then, on the command line, you run cucumber:

        $ cucumber

And you watch the lines zip by.

That should be all (-:

Over the next few days, I hope to fill out the test suite with more
interesting examples that you can use as a reference.
