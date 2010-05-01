require 'fileutils'

class ClucumberWorld
  extend Forwardable
  def_delegators ClucumberWorld, :examples_dir, :self_test_dir, :working_dir

  def self.self_test_dir(subdir=nil)
    @examples_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../self_test'))
    subdir ? File.join(@examples_dir, subdir) : @examples_dir
  end

  def self.working_dir
    @working_dir ||= self_test_dir('tmp')
  end

  def initialize
    @current_dir = self_test_dir
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def create_file(file_name, file_content)
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name)) unless File.directory?(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      mode = Cucumber::RUBY_1_9 ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{command} 2> #{stderr_file.path}", mode) do |io|
        @last_stdout = io.read
      end
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end
end

World do
  ClucumberWorld.new
end

Before do
  FileUtils.rm_rf ClucumberWorld.working_dir
  FileUtils.mkdir ClucumberWorld.working_dir
end


# Start the main clucumber file

require File.expand_path("../../clucumber.rb", File.dirname(__FILE__))
begin
  @main_clucumber = ClucumberSubprocess.new(File.expand_path("../", File.dirname(__FILE__)),
                                           :port => 42428)
  at_exit do
    @main_clucumber.kill
    FileUtils.rm_f File.expand_path("../step_definitions/clucumber.wire", File.dirname(__FILE__))
  end

  @main_clucumber.start <<-LISP
    ;; Load the current dir's system definition,
    ;; not what might be linked somewhere in the system:
    (load #p"#{File.expand_path("../../clucumber.asd", File.dirname(__FILE__))}")
  LISP
rescue PTY::ChildExited
  puts(@main_clucumber && @main_clucumber.output)
end
