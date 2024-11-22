module JunitTimingSplitter
  class Parser
    attr_reader :file_paths, :files, :parsed_timings

    def initialize(file_paths)
      @file_paths = file_paths
      @files = Dir.glob(file_paths)
      @parsed_timings = []

      puts "Detected #{files.size} files"
      @files.each { |file| puts "Detected file: #{file}" }
    end

    # Parse multiple rspec-results.xml files into a list of files and their execution times
    def execute
      files.each do |file_path|
        File.open(file_path) do |file|
          doc = Nokogiri::XML(file)

          doc.xpath('//testcase').each do |testcase|
            file = testcase['file']
            time = testcase['time'].to_f
            next if file.nil? || time.nil?

            existing = @parsed_timings.find { |pd| pd.file == file }
            if existing
              existing.total_time += time
              existing.total_testcases += 1
            else
              @parsed_timings << ParsedTiming.new(file: file, total_time: time)
            end
          end
        end
      end

      @parsed_timings
    end
  end
end
