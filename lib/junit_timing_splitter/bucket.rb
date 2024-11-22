module JunitTimingSplitter
  class Bucket
    attr_accessor :files, :total_time

    def initialize(files: [], total_time: 0.0)
      @files = files
      @total_time = total_time
    end

    def to_h
      {
        files: @files,
        total_time: @total_time
      }
    end

    def to_s
      files.join(' ')
    end
  end
end
