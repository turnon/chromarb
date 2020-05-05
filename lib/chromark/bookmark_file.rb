class Chromark
  module BookmarkFile

    class Category
      attr_reader :added, :moded, :name, :parent

      def initialize(added, moded, name, parent)
        @added = added
        @moded = moded
        @name = name
        @parent = parent
        @entries = []
      end

      def <<(entry)
        @entries << entry
      end

      def path_str
        @path_str ||= parent ? parent.path_str  + "/" + name : "/"
      end
    end

    class Entry
      attr_reader :href, :added, :name, :parent

      def initialize(href, added, name, parent)
        @href = href
        @added = added
        @name = name
        @parent = parent
        parent << self
      end

      def path_str
        parent.path_str
      end

      def host
        @host ||= URI.parse(href).host rescue "nil"
      end
    end

    def entries
      @entries ||= []
    end

    def dup_names
      return @dup_names if @dup_names

      @dup_names = {}
      entries.group_by(&:name).each do |name, es|
        next if es.size == 1
        @dup_names[name] = es.map(&:path_str)
      end
      @dup_names
    end

    def favorite_hosts
      @favorite_hosts ||= entries.group_by(&:host).
        map{ |host, entries| [host, entries.size] }.
        select{ |h| h[1] > 1 }.
        sort{ |h1, h2| h2[1] <=> h1[1] }.
        to_h
    end

  end
end