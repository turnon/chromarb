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
        @path_str ||= parent ? File.join(parent.path_str, name) : "/"
      end

      def deep
        @deep ||= parent ? parent.deep + 1 : 0
      end
    end

    class Entry
      attr_reader :href, :added, :name, :parent

      def initialize(href, added, name, parent)
        @href = href
        @added = added
        @name = name
        @parent = parent
        parent << self if parent
      end

      def path_str
        parent ? parent.path_str : "/"
      end

      def deep
        parent ? parent.deep : 0
      end

      def host
        @host ||= URI.parse(href).host rescue "nil"
      end
    end

    def entries
      @entries ||= []
    end

    def stats
      Stat.sub_stats.map{ |sub| sub.new(self) }
    end

    class Stat
      attr_reader :file, :data

      class << self
        attr_reader :sub_stats

        def inherited(base)
          (@sub_stats ||= []) << base
        end
      end

      def initialize(file)
        @file = file
        @data = analyze
      end

      def group_by(
        elements,
        attribute,
        filter: ->(name, entries){ entries.size > 1 },
        sortor: ->(e1, e2){ e2[1].size <=> e1[1].size }
      )

        hash = elements.group_by(&attribute)
        hash = hash.select(&filter) if filter
        hash = hash.sort(&sortor) if sortor
        hash.to_h
      end
    end

    class DupNames < Stat
      def analyze
        group_by(file.entries, :name)
      end
    end

    class FavoriteHosts < Stat
      def analyze
        group_by(file.entries, :host)
      end
    end

    class Categories < Stat
      def analyze
        group_by(file.entries, :path_str)
      end
    end

    class Deep < Stat
      def analyze
        group_by(file.entries, :deep, filter: nil, sortor: ->(e1, e2){ e1[0] <=> e2[0] })
      end
    end

  end
end