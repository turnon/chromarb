class Chromark
  class JsonFormat
    include BookmarkFile

    class Node
      def initialize(json, file, parent)
        if json["type"] = "url"
          e = BookmarkFile::Entry.new(json["url"], json["date_added"], json["name"], parent)
          file.entries << e
        end

        cate = BookmarkFile::Category.new(json["date_added"], json["date_modified"], json["name"], parent)

        return unless json["children"]
        json["children"].each do |child|
          Node.new(child, file, cate)
        end
      end
    end

    def initialize
      file = File.join('C:', 'Users', ENV['USERNAME'], 'AppData',
        'Local', 'Google', 'Chrome', 'User Data', 'Default', 'Bookmarks')

      json = JSON.parse File.read file

      Node.new(json["roots"]["bookmark_bar"], self, nil)
    end

  end
end