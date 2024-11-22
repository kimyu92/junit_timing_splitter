require 'nokogiri'
require "zeitwerk"
require 'thor'
require 'json'

# Example Usage:
# To analyze all XML files:
# parsed_timings = JunitTimingSplitter::Parser.new('results_*.xml').execute
# buckets = JunitTimingSplitter::Split.new(parsed_timings, 5).execute
module JunitTimingSplitter
  loader = Zeitwerk::Loader.for_gem
  loader.setup # ready!
end
