require 'minitest/autorun'
require 'junit_timing_splitter'
require 'json'

class TestJunitTimingSplitter < Minitest::Test
  def setup
    @simple_glob = File.join(File.dirname(__FILE__), 'fixtures', 'results_0[0-1].xml')
    @imbalanced_glob = File.join(File.dirname(__FILE__), 'fixtures', 'results_0[2-3].xml')

    # Create a temporary schema file for testing
    @schema_path = File.join(File.dirname(__FILE__), 'fixtures', 'schema.json')
    @schema_content = [
      { 'files' => ['./spec/models/simple_part1_spec.rb'], 'total_time' => 10.0 },
      { 'files' => ['./spec/models/simple_part2_spec.rb'], 'total_time' => 10.0 }
    ]
    File.write(@schema_path, JSON.pretty_generate(@schema_content))
  end

  def teardown
    # Clean up temporary schema file
    File.delete(@schema_path) if File.exist?(@schema_path)
  end

  # Test the simple case
  def test_simple_case
    # Parse and analyze the simple test case
    parser = JunitTimingSplitter::Parser.new(@simple_glob)
    timings = parser.execute
    assert_equal 2, timings.size, 'Total test files parsed should be 2'

    timings.each do |timing|
      assert_equal 4, timing.total_testcases, "Total test cases for #{timing.file} file should be 3"

      assert_includes(
        ['./spec/models/simple_part1_spec.rb', './spec/models/simple_part2_spec.rb'],
        timing.file,
        "#{timing.file} test file exist in the list"
      )

      # Verify total times for each simple test case
      assert_equal 10.0, timing.total_time, "Total time for #{timing.file} file should be 10.0"
    end

    # Test splitting logic for the simple case
    splitter = JunitTimingSplitter::Splitter.new(timings, 2)
    buckets = splitter.execute
    assert_equal 2, buckets.size, 'There should be 2 buckets'

    # Check bucket distribution
    assert_in_delta 10.0, buckets[0].total_time, 1.0, 'Bucket 1 should have balanced total time'
    assert_in_delta 10.0, buckets[1].total_time, 1.0, 'Bucket 2 should have balanced total time'
  end

  def test_imbalanced_case
    # Parse and analyze the imbalanced test case
    parser = JunitTimingSplitter::Parser.new(@imbalanced_glob)
    timings = parser.execute
    assert_equal 7, timings.size, 'Total test files parsed should be 3 + 4 = 7'

    # Test splitting logic for the imbalanced case
    splitter = JunitTimingSplitter::Splitter.new(timings, 2)
    buckets = splitter.execute
    assert_equal 2, buckets.size, 'There should be 2 buckets'

    # Check bucket distribution
    assert_in_delta 32.0, buckets[0].total_time, 1.0, 'Bucket 1 should have balanced total time'
    assert_in_delta 30.0, buckets[1].total_time, 1.0, 'Bucket 2 should have balanced total time'
  end

  def test_files_for_bucket
    schema = JunitTimingSplitter::Schema.new(@schema_path)
    files = schema.files_for_bucket(0)
    assert_equal ['./spec/models/simple_part1_spec.rb'], files, 'Bucket 0 should contain simple_part1_spec.rb'

    files = schema.files_for_bucket(1)
    assert_equal ['./spec/models/simple_part2_spec.rb'], files, 'Bucket 1 should contain simple_part2_spec.rb'

    files = schema.files_for_bucket(2)
    assert_empty files, 'Bucket 2 should not exist'
  end

  def test_all_parsed_files
    schema = JunitTimingSplitter::Schema.new(@schema_path)
    all_files = schema.all_parsed_files
    expected_files = [
      './spec/models/simple_part1_spec.rb',
      './spec/models/simple_part2_spec.rb'
    ]
    assert_equal expected_files.sort, all_files.sort, 'All parsed files should match the expected files'
  end

  def test_scan_missing_files
    schema = JunitTimingSplitter::Schema.new(@schema_path)

    # Create mock files for testing
    folder_path = File.expand_path(File.join(__dir__, '..', 'spec', 'models'))

    # Create the directory if it does not exist
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)
    File.write("#{folder_path}/simple_part1_spec.rb", '') # Existing file
    File.write("#{folder_path}/missing_test.rb", '') # Missing file

    glob_path = "#{folder_path}/**/*.rb"
    missing_files = schema.scan_missing_files(glob_path)

    assert_equal ["#{folder_path}/missing_test.rb"], missing_files, 'Missing test should be detected'

    # Cleanup
    File.delete("#{folder_path}/simple_part1_spec.rb") if File.exist?("#{folder_path}/simple_part1_spec.rb")
    File.delete("#{folder_path}/missing_test.rb") if File.exist?("#{folder_path}/missing_test.rb")
    FileUtils.rm_rf(folder_path) if Dir.exist?(folder_path)
  end

  def test_scan_without_missing_files
    schema = JunitTimingSplitter::Schema.new(@schema_path)

    # Create mock files for testing
    folder_path = File.expand_path(File.join(__dir__, '..', 'spec', 'models'))

    # Create the directory if it does not exist
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)
    File.write("#{folder_path}/simple_part1_spec.rb", '') # Existing file
    File.write("#{folder_path}/simple_part2_spec.rb", '') # Existing file

    glob_path = "#{folder_path}/**/*.rb"
    missing_files = schema.scan_missing_files(glob_path)

    assert_empty missing_files, 'There should be no missing tests'

    # Cleanup
    File.delete("#{folder_path}/simple_part1_spec.rb") if File.exist?("#{folder_path}/simple_part1_spec.rb")
    File.delete("#{folder_path}/simple_part2_spec.rb") if File.exist?("#{folder_path}/simple_part2_spec.rb")
    FileUtils.rm_rf(folder_path) if Dir.exist?(folder_path)
  end

  def test_merge_missing_files
    schema = JunitTimingSplitter::Schema.new(@schema_path)

    # Create mock files for testing
    folder_path = File.expand_path(File.join(__dir__, '..', 'spec', 'models', 'merge'))
    existing_folder_path = File.expand_path(File.join(__dir__, '..', 'spec', 'models'))

    # Create the directory if it does not exist
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)
    File.write("#{existing_folder_path}/simple_part1_spec.rb", '') # Existing file
    File.write("#{existing_folder_path}/simple_part2_spec.rb", '') # Existing file
    File.write("#{folder_path}/missing_test1.rb", '') # Missing file
    File.write("#{folder_path}/missing_test2.rb", '') # Missing file

    glob_path = "#{folder_path}/**/*.rb"
    missing_files = schema.scan_missing_files(glob_path)

    # Merge missing files into buckets
    splitter = JunitTimingSplitter::Splitter.new([], 2)
    buckets = splitter.merge_missing_files(missing_files)

    assert_equal 2, buckets.size, 'There should be 2 buckets after merging missing files'
    assert_includes buckets[0].files, "#{folder_path}/missing_test1.rb", 'Bucket 0 should contain missing_test1.rb'
    assert_includes buckets[1].files, "#{folder_path}/missing_test2.rb", 'Bucket 1 should contain missing_test2.rb'

    # Cleanup
    File.delete("#{existing_folder_path}/simple_part1_spec.rb") if File.exist?("#{existing_folder_path}/simple_part1_spec.rb")
    File.delete("#{existing_folder_path}/simple_part2_spec.rb") if File.exist?("#{existing_folder_path}/simple_part2_spec.rb")
    File.delete("#{folder_path}/missing_test1.rb") if File.exist?("#{folder_path}/missing_test1.rb")
    File.delete("#{folder_path}/missing_test2.rb") if File.exist?("#{folder_path}/missing_test2.rb")
    FileUtils.rm_rf(folder_path) if Dir.exist?(folder_path)
  end
end
