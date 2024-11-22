module JunitTimingSplitter
  class Schema
    attr_reader :path, :buckets

    def initialize(path)
      @path = path
      validate_file
      @buckets = JSON.parse(File.read(path))
    end

    # Retrieve files from a specific bucket
    def files_for_bucket(bucket_number)
      bucket = buckets[bucket_number]
      bucket ? bucket['files'] : []
    end

    # Retrieve all parsed files across all buckets
    def all_parsed_files
      buckets.flat_map { |bucket| bucket['files'] }
    end

    # Scan for missing files in a specified glob path
    def scan_missing_files(glob_path)
      parsed_files = all_parsed_files.map { |file| File.expand_path(file) }
      all_files = Dir.glob(glob_path).map { |file| File.expand_path(file) }
      all_files - parsed_files
    end

    private

    def validate_file
      unless File.exist?(path)
        raise IOError, "Schema file not found: #{path}"
      end
    end
  end
end
