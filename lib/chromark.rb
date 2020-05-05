require "chromark/version"
require "erb"
require "json"

require "chromark/bookmark_file"
require "chromark/html"
require "chromark/json_format"

class Chromark

  class << self
    def parse
      raise "bookmark file not given" if ARGV.size == 0
      new(JsonFormat.new).parse
    end
  end

  attr_reader :file

  def initialize(file)
    @file = file
  end

  def parse
    template = File.read File.expand_path("../chromark/chart.erb", __FILE__)
    res = ERB.new(template).result(binding)
    File.open(File.join(Dir.pwd, "bookmark_stat.html"), "w"){ |f| f.puts res }
  end

  BookmarkFile.instance_methods.each do |m|
    define_method(m) do
      file.send(m)
    end
  end

end
