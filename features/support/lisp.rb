class ClucumberSubprocess
  attr_reader :output, :lisp

  def initialize(dir, options={})
    lisp = options[:lisp] || ENV['LISP'] || 'sbcl --disable-debugger'
    @port = options[:port] || raise("Need a port to run clucumber on.")
    @output = ""
    Dir.chdir(dir) do
      @lisp = IO.popen("#{lisp}", "r+")
      Thread.new do
        while output = @lisp.read
          ClucumberRunner.record_output(output)
        end
      end
      @lisp.puts(<<-LISP)
(require :asdf)
(asdf:oos 'asdf:load-op :clucumber)
(clucumber-external:start #p"./" "localhost" #{@port}))
LISP
    end
  end
  
  def wait_until_started()
    until socket = TCPSocket.new("localhost", @port) rescue nil
      sleep 0.2
    end
    socket.close
  end

  def record_output(output)
    @output << output
  end

  def kill
    Process.kill("TERM", @lisp.pid) if @lisp
    @lisp = nil
  end

  def alive?
    !@lisp.nil?
  end
end
