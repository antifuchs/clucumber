require 'pty'

class ClucumberSubprocess
  attr_reader :output

  def initialize(dir, options={})
    @dir = dir
    lisp = options[:lisp] || ENV['LISP'] || 'sbcl --disable-debugger'
    @port = options[:port] || raise("Need a port to run clucumber on.")
    @output = ""
    
    Dir.chdir(@dir) do
      @out, @in, @pid = PTY.spawn(lisp)
    end
    @reader = Thread.start {
      record_output
    }
    @in.puts(<<-LISP)
      (require :asdf)
    LISP
  end
  
  def start(additional_forms="")
    @in.puts <<-LISP
      #{additional_forms}
      (asdf:oos 'asdf:load-op :clucumber)
      (clucumber-external:start #p"./" "localhost" #{@port})
    LISP
    until socket = TCPSocket.new("localhost", @port) rescue nil
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
    !@pid.nil?
  end
end
