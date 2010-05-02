require "../../clucumber.rb"

begin
  @main_clucumber = ClucumberSubprocess.new(File.expand_path("../", File.dirname(__FILE__)),
                                            :port => 42427)
  at_exit do
    @main_clucumber.kill
  end

  @main_clucumber.start <<-LISP
  (asdf:oos 'asdf:load-op :clucumber)
  (setf clucumber::*print-backtraces* nil)
  LISP
rescue PTY::ChildExited
  puts(@main_clucumber && @main_clucumber.output)
end
