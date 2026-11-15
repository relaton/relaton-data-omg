# frozen_string_literal: true

source "https://rubygems.org"

# Pin psych: 5.3.0 silently breaks the YAML round-trip that check_data.rb
# depends on (key ordering / quoting differences). Documented in
# relaton-data-oiml Gemfile.
gem "psych", "~> 5.2.6"

# relaton is the single combined v3 gem. The OMG flavor lives inside it at
# lib/relaton/omg/ — its Scraper parses every spec/version page for us.
gem "relaton",
    git: "https://github.com/relaton/relaton.git",
    branch: "main"

# pubid v2 parses primary docids into structured identifiers for the
# pubid_class-based index-v2.yaml. Track pubid main; flip to the released
# gem when pubid v2 ships (the IALA convention).
gem "pubid",
    git: "https://github.com/metanorma/pubid.git",
    branch: "main"

# relaton main depends on rubyzip ~> 3.7 (relaton#264); match it —
# crawler.rb compresses index*.yaml → index*.zip.
gem "rubyzip", "~> 3.7"

# The former exact pin ("1.9.362.1 is the only published line") died in the
# yank wave that removed the whole 1.9.36x line — fresh resolution failed
# daily from 2026-11-13. relaton main's gemspec now floors leptris
# `~> 1.9.391`, a live published line; no local pin needed.

group :development, :test do
  gem "rspec", "~> 3.13"
  gem "webmock"
end
