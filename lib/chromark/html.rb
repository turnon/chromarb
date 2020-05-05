class Chromark
  class Html
    include BookmarkFile

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

    def initialize
      @cate_stack = []

      ARGF.each do |line|
        case line
        when /\s*<DT><A/
          e = Entry.new(line, @cate_stack)
          entries << e
        when /\s*<DT><H3/
          c = Category.new(line)
          @cate_stack << c
        when /\s*<\/DL><p>/
          @cate_stack.pop
        end
      end
    end

  end
end