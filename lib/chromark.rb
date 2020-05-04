require "chromark/version"
require "erb"
require "json"

class Chromark

  class Category
    attr_reader :added, :moded, :name

    def initialize(line)
      m = line.match(/.*ADD_DATE="(.*)" LAST_MODIFIED="(.*)">(.*)<\/H3>/)
      @added = m[1]
      @moded = m[2]
      @name = m[3]
      @entries = []
    end

    def <<(entry)
      @entries << entry
    end
  end

  class Entry
    attr_reader :href, :added, :name, :path

    def initialize(line, path)
      m = line.match(/<.*HREF="(.*)" ADD_DATE="(.*)".*>(.*)<\/A>/)
      @href = m[1]
      @added = m[2]
      @name = m[3]
      @path = path.dup
      path.last << self
    end

    def path_str
      @path_str ||= @path.size == 1 ? '/' : ('/' + @path[1..-1].map(&:name).join('/'))
    end

    def host
      @host ||= URI.parse(href).host rescue "nil"
    end
  end

  class << self
    def parse
      raise "bookmark file not given" if ARGV.size == 0
      new.parse
    end
  end

  def initialize
    @entries = []
    @cates = []
    @root = nil

    ARGF.each do |line|
      case line
      when /\s*<DT><A/
        e = Entry.new(line, @cates)
        @entries << e
      when /\s*<DT><H3/
        c = Category.new(line)
        @root ||= c
        @cates << c
      when /\s*<\/DL><p>/
        @cates.pop
      end
    end
  end

  def parse
    template = File.read File.expand_path("../chromark/chart.erb", __FILE__)
    res = ERB.new(template).result(binding)
    File.open(File.join(Dir.pwd, "bookmark_stat.html"), "w"){ |f| f.puts res }
  end

  private

  def dup_names
    return @dup_names if @dup_names

    @dup_names = {}
    @entries.group_by(&:name).each do |name, es|
      next if es.size == 1
      @dup_names[name] = es.map(&:path_str)
    end
    @dup_names
  end

  def favorite_hosts
    @favorite_hosts ||= @entries.group_by(&:host).
      map{ |host, entries| [host, entries.size] }.
      select{ |h| h[1] > 1 }.
      sort{ |h1, h2| h2[1] <=> h1[1] }.
      to_h
  end

end
