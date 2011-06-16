require 'fileutils'
require 'tempfile'
require 'aruba'
require 'aruba/cucumber'

require File.expand_path("../../lib/clucumber.rb", File.dirname(__FILE__))

class ClucumberWorld
  def strip_duration(s)
    s.gsub(/^\d+m\d+\.\d+s\n/m, "")
  end
end

World do
  ClucumberWorld.new
end


# Monkey patch Arube to filter some crap out:
module Aruba::Api
  alias __all_stdout all_stdout
  
  def all_stdout
    unrandom(__all_stdout)
  end

  def unrandom(out)
    out.
      gsub(/#{Dir.pwd}\/tmp\/aruba/, '.'). # Remove absolute paths
      gsub(/^\d+m\d+\.\d+s$/, ''). # Make duration predictable
      gsub(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '')     # Remove SimpleCov message
  end
end
