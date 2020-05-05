class Chromark
  class Html
    include BookmarkFile

    def initialize
      cate_stack = []

      ARGF.each do |line|
        case line
        when /\s*<DT><A/
          m = line.match(/<.*HREF="(.*)" ADD_DATE="(.*)".*>(.*)<\/A>/)
          e = BookmarkFile::Entry.new(m[1], m[2], m[3], cate_stack.last)
          entries << e
        when /\s*<DT><H3/
          m = line.match(/.*ADD_DATE="(.*)" LAST_MODIFIED="(.*)">(.*)<\/H3>/)
          c = BookmarkFile::Category.new(m[1], m[2], m[3], cate_stack.last)
          cate_stack << c
        when /\s*<\/DL><p>/
          cate_stack.pop
        end
      end
    end

  end
end