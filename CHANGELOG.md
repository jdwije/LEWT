# Change Log

## 0.5.13 - 0.5.15
- FIXED: Path loads for test data when installing from ruby gems (took a couple of tries)

## 0.5.12
- FIXED: GEM extension loading
- ADDED: ability to generate frequency table without correlations in metastat, party due to the later being incomplete
- REFACTORED: naming conventions used for functions throughout extensions
- ADDED: Version flag to CL and linked it to the LEWT module
- ADDED: test data for milestones and expenses extractors

## 0.5.11
- IMPROVED: Types used for date calculations in calendar extractors
- ADDED: Dummy iCal data file for testing things out with
- FIXED: settings load paths on fresh install
- FIXED: extension load paths on fresh install
- FIXED: Persisting LEWT settings between updates, now supports ~/.lewt_settings config file

## 0.5.10
- IMPROVED: metastat now does correlations
- IMPROVED: documentation has been updated to reflect the most recent changes
- ADDED: namespacing to LEWT using ruby's module feature
- FIXED: Time handling in LEWT ledger. Now requires UNIX 'Time()' object for these fields instead of DateTime.
- FIXED: Piping input bugs
- FIXED: Invoice monetary rounding issue
- IMPROVED: Default template styles for HTML & PDF output in liquid render extension
- IMPROVED: Invoice ID algorithm, it now includes a short hex string to make for easier file system indexing.
- ADDED: Added recursive file saving ability to store and liquid render.

## 0.5.9
- IMPROVED: metastats extension. now does better tallying and some statistics.
- REFACTORED: function names throughout LEWT to use this_naming_convention instead of camel case

## 0.5.8
- ADDED: meta logging to LEWTLedger class
- FIXED: Loading paths bug
- IMPROVED: Project documentation now marked up for rdoc much better
- IMPROVED: LEWTOpts class now uses symbols instead of strings for options translation
- ADDED: Store plugin for persisting data

## 0.5.7
- ADDED: Simple Milestone extractor
- FIXED: Expenses extractor bug where client targeting wasn't working properly

## 0.5.6
- ADDED: Methods for calendar extractor to work with OSX calendar
