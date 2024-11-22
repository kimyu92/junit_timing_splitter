module JunitTimingSplitter
  class Splitter
    attr_reader :parsed_timings, :total_splits, :buckets

    def initialize(parsed_timings, total_splits)
      @parsed_timings = parsed_timings
      @total_splits = total_splits
      @buckets = Array.new(total_splits) { Bucket.new }
    end

    # Split the parsed timings into buckets based on total_splits
    def execute
      # Sort by time descending
      sorted_timings = parsed_timings.sort_by { |parsed_timing| -parsed_timing.total_time }

      # Initialize buckets
      @buckets = Array.new(total_splits) { Bucket.new }

      # Greedily distribute files to minimize total time imbalance
      sorted_timings.each do |timing|
        min_bucket = @buckets.min_by { |bucket| bucket.total_time }
        min_bucket.files << timing.file
        min_bucket.total_time += timing.total_time
      end

      @buckets
    end

    def merge_missing_files(missing_files)
      missing_files.each_with_index do |file, index|
        bucket = @buckets[index % total_splits]
        bucket.files << file
        # Assuming a default time for missing files, e.g., 1.0
        bucket.total_time += 1.0
      end
      @buckets
    end

    # Command to display a specific split, start with index 0
    def inspect(split_number: nil)
      unless split_number
        buckets.each_with_index do |bucket, index|
          puts "[BUCKET #{index} - #{bucket.total_time.round(2)}s] #{bucket.files.join(', ')}"
        end

        return
      end

      # split_number exists
      if split_number > total_splits - 1
        puts "Invalid split number. Total splits: #{total_splits}"
        return
      end

      specific_bucket = buckets[split_number]
      puts "[BUCKET #{split_number} - #{specific_bucket.total_time.round(2)}s] #{specific_bucket.files.join(', ')}"
    end
  end
end
