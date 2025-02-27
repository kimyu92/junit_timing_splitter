# Change Log

## [Unreleased]

## v1.1.0
Improvements
- Added GitHub Actions CI configuration to run on push to any branch and on merge to main.

Bug Fixes
- Fixed an issue where merging missing test files would overwrite previously assigned test cases in buckets.
- Updated CLI and Splitter to accept an existing schema, ensuring that previous test assignments remain intact while merging missing tests.

## v1.0.0
- Initial release of JunitTimingSplitter with test parsing, splitting, schema generation, and basic merge functionality.
