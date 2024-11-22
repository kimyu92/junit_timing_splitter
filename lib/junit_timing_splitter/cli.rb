# The CLI to split testcases into n buckets and read a specific bucket
module JunitTimingSplitter
  class Cli < Thor
    desc 'split', 'Split test files by timing'
    option :files, required: true, aliases: '-f', desc: 'Glob path to scan for test files'
    option :buckets, required: true, aliases: '-b', type: :numeric, desc: 'Number of buckets'
    option :schema, required: true, aliases: '-o', desc: 'Output JSON file that contains information for each bucket'
    def split
      parsed_timings = JunitTimingSplitter::Parser.new(options[:files]).execute
      buckets = JunitTimingSplitter::Splitter.new(parsed_timings, options[:buckets]).execute
      buckets_as_hashes = buckets.map(&:to_h)
      FileUtils.mkdir_p(File.dirname(options[:schema]))
      File.write(options[:schema], JSON.pretty_generate(buckets_as_hashes))
      puts "Buckets written to #{options[:schema]}"
    end

    desc 'show', 'Show test files of a specific bucket from JSON file'
    option :schema, required: true, aliases: '-s', desc: 'Specific Generated JSON file from split step'
    option :bucket, required: true, aliases: '-i', type: :numeric, desc: 'Bucket number to read'
    def show
      begin
        schema = JunitTimingSplitter::Schema.new(options[:schema])
        files = schema.files_for_bucket(options[:bucket].to_i)

        if files.any?
          puts files.join(' ')
        else
          puts 'Bucket not found'
          exit(1)
        end
      rescue IOError => e
        puts e.message
        exit(1)
      end
    end

    desc 'scan', 'Scan folder or glob path for missing test files'
    option :schema, required: true, aliases: '-s', desc: 'Specific Generated JSON file from split step'
    option :files, required: true, aliases: '-f', desc: 'Glob path to scan for test files'
    def scan
      begin
        schema = JunitTimingSplitter::Schema.new(options[:schema])
        missing_files = schema.scan_missing_files(options[:files])

        if missing_files.empty?
          puts 'No missing test files detected.'
        else
          puts 'Missing test files:'
          missing_files.each { |file| puts file }
        end
      rescue IOError => e
        puts e.message
        exit(1)
      end
    end

    desc 'merge', 'Merge missing test files into buckets'
    option :schema, required: true, aliases: '-s', desc: 'Specific Generated JSON file from split step'
    option :files, required: true, aliases: '-f', desc: 'Glob path to scan for test files'
    def merge
      begin
        schema = JunitTimingSplitter::Schema.new(options[:schema])
        missing_files = schema.scan_missing_files(options[:files])

        if missing_files.empty?
          puts 'No missing test files to merge.'
        else
          splitter = JunitTimingSplitter::Splitter.new([], schema.buckets.size)
          buckets = splitter.merge_missing_files(missing_files)
          buckets_as_hashes = buckets.map(&:to_h)
          File.write(options[:schema], JSON.pretty_generate(buckets_as_hashes))
          puts "Missing files merged into buckets and written to #{options[:schema]}"
        end
      rescue IOError => e
        puts e.message
        exit(1)
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
