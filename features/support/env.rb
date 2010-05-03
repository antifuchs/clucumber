require 'fileutils'
require 'tempfile'
require 'aruba'
require File.expand_path("../../lib/clucumber.rb", File.dirname(__FILE__))

class ClucumberWorld
  def strip_duration(s)
    s.gsub(/^\d+m\d+\.\d+s\n/m, "")
  end
end

World do
  ClucumberWorld.new
end
