require 'clucumber'

begin
  @main_clucumber = ClucumberSubprocess.launch(File.expand_path("../", File.dirname(__FILE__)))
  @main_clucumber.listen <<-LISP
      ;; Put code here that loads your application.
  LISP
rescue PTY::ChildExited
  STDERR.puts "Clucumber failed to launch:"
  STDERR.puts(@main_clucumber && @main_clucumber.output)
end
