require File.expand_path("../../../../lib/clucumber.rb", File.dirname(__FILE__))

begin
  ClucumberSubprocess.launch(File.expand_path("../", File.dirname(__FILE__)),
                             :port => 42427).listen <<-LISP
  (asdf:oos 'asdf:load-op :clucumber)
  (setf clucumber::*print-backtraces* nil)
  LISP
rescue PTY::ChildExited
  puts(@main_clucumber && @main_clucumber.output)
end
