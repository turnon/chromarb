class Chromark
  module BookmarkFile

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