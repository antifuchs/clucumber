require 'pty'
require 'fileutils'

class ClucumberSubprocess
  class LaunchFailed < RuntimeError; end
  
  attr_reader :output

  def self.launch(dir, options={})
    proc = ClucumberSubprocess.new(dir, options)
    at_exit do
      proc.kill
    end
    proc.run
    proc
  end
  
  def initialize(dir, options={})
    @dir = dir
    @lisp = options[:lisp] || ENV['LISP'] || 'sbcl --disable-debugger'
    @port = options[:port] || raise("Need a port to run clucumber on.")
    @output = ""
  end

  def run
    Dir.chdir(@dir) do
      @out, @in, @pid = PTY.spawn(@lisp)
    end
    @reader = Thread.start {
      record_output
    } 
    cluke_dir = File.expand_path("clucumber/", File.dirname(__FILE__))
    Dir[cluke_dir + '/**/*.fasl'].each do |fasl|
      FileUtils.rm(fasl)
    end
    @in.puts(<<-LISP)
      (load #p"#{File.expand_path("clucumber/clucumber-bootstrap.lisp", File.dirname(__FILE__))}")
    LISP
  end
  
  def listen(additional_forms="")
    @in.puts <<-LISP
      #{additional_forms}
      (asdf:oos 'asdf:load-op :clucumber)
      (clucumber-external:start #p"./" "localhost" #{@port})
    LISP
    until socket = TCPSocket.new("localhost", @port) rescue nil
      raise LaunchFailed, "Couldn't start clucumber:\n#{@output}" unless alive?
      sleep 0.01
    end
    File.open(File.join(@dir, "step_definitions", "clucumber.wire"), "w") do |out|
      YAML.dump({'host' => "localhost", 'port' => @port}, out)
    end
    socket.close
  end

  def record_output
    begin
      while line = @out.readline
        @output << line
      end
    rescue PTY::ChildExited
      STDOUT.puts "child exited, stopping."
      nil
    end
  end

  def kill
    if @pid
      FileUtils.rm_f File.join(@dir, "step_definitions", "clucumber.wire")
      @reader.terminate!
      Process.kill("TERM", @pid)
      Process.waitpid(@pid)
      @pid = nil
    end
  rescue PTY::ChildExited
    @pid = nil
  end

  def alive?
    if !@pid.nil?
      (Process.kill("CONT", @pid) && true) rescue false
    end
  end

  def vendor_path
    File.expand_path("../clucumber/vendor/", __FILE__)
  end

  def vendor_libs
    Dir[vendor_path + '/*'].map {|dir| File.basename(dir)}
  end
end
