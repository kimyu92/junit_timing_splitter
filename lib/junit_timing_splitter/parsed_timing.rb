module JunitTimingSplitter
  class ParsedTiming
    attr_accessor :file, :total_time, :total_testcases

    def initialize(file:, total_time:, total_testcases: 1)
      @file = file
      @total_time = total_time
      @total_testcases = total_testcases
    end
  end
end
