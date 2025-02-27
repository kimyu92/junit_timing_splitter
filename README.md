# JunitTimingSplitter

[![GemVersion](https://img.shields.io/gem/v/junit_timing_splitter.svg?style=flat)](https://rubygems.org/gems/junit_timing_splitter)
![CI](https://github.com/kimyu92/junit_timing_splitter/workflows/CI/badge.svg)

`JunitTimingSplitter` is a tool written in Ruby designed to parse JUnit XML result files and distribute tests into evenly balanced buckets based on their total execution time. This tool is especially beneficial for optimizing parallel test execution in CI pipelines, drawing inspiration from CircleCI's `--split-by=timings` feature.

---

## Features

- Parse JUnit XML files (`*.xml`) to extract test file execution times.
- Aggregate timings across multiple XML files.
- Split tests into evenly distributed buckets based on execution time.
- Analyze bucket distribution for load balancing.
- Compatible with glob patterns to process multiple XML files.

---

## Installation

Add this gem to your `Gemfile`:

```sh
gem install junit_timing_splitter
```

or

```ruby
# Gemfile
gem 'junit_timing_splitter', '~> 1.0.0'
```

Then,

```sh
bundle install
```

## Usage
1. Generate Junit XML Results
Analyze how test files will be distributed across N buckets:

```sh
bundle exec junit_timing_splitter split --files="test/fixtures/results_0[0|1].xml" --buckets=2 --schema="output/buckets.json"
```

```
Detected 2 files
Detected file: test/fixtures/results_00.xml
Detected file: test/fixtures/results_01.xml
Buckets written to buckets.json
```

2. Get Files for a Specific Bucket
```sh
bundle exec junit_timing_splitter show --schema="output/buckets.json" --bucket=0
bundle exec junit_timing_splitter show --schema="output/buckets.json" --bucket=1
```

```
# bucket=0
./spec/models/simple_part1_spec.rb

# bucket=1
./spec/models/simple_part2_spec.rb
```

3. Find out the missing test cases from the existing schema

```sh
bundle exec junit_timing_splitter scan --schema="output/buckets.json" --files="./spec/**/*.rb"
```

```
# if no missing file
No missing test files detected.

# if missing exist
Missing test files:
<absolute path>/spec/models/missing_test.rb
```

4. Merge the missing test cases from the existing schema
```sh
bundle exec junit_timing_splitter merge --schema="output/buckets.json" --files="./spec/**/*_spec.rb"
```

## Development

```sh
# rebuild
rm junit_timing_splitter-1.1.0.gem && gem build JunitTimingSplitter.gemspec && gem install junit_timing_splitter-1.1.0.gem
```

```sh
# testing
ruby test/test_junit_timing_splitter.rb --verbose

Run options: --verbose --seed 58633

# Running:

TestJunitTimingSplitter#test_merge_missing_files = 0.00 s = .
TestJunitTimingSplitter#test_simple_case = Detected 2 files
Detected file: test/fixtures/results_00.xml
Detected file: test/fixtures/results_01.xml
0.00 s = .
TestJunitTimingSplitter#test_scan_without_missing_files = 0.00 s = .
TestJunitTimingSplitter#test_all_parsed_files = 0.00 s = .
TestJunitTimingSplitter#test_imbalanced_case = Detected 2 files
Detected file: test/fixtures/results_02.xml
Detected file: test/fixtures/results_03.xml
0.00 s = .
TestJunitTimingSplitter#test_scan_missing_files = 0.00 s = .
TestJunitTimingSplitter#test_files_for_bucket = 0.00 s = .

Finished in 0.008489s, 824.5965 runs/s, 3416.1856 assertions/s.

7 runs, 29 assertions, 0 failures, 0 errors, 0 skips
```

## License
Copyright (c) 2024 Kim Yu Ng, released under the [MIT license](LICENSE.md)
