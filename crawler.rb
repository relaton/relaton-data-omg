#!/usr/bin/env ruby
# frozen_string_literal: true

# Crawler entry point (the relaton/support workflow runs `bundle exec ruby
# crawler.rb`, then commits the index*.yaml / index*.zip it produces).
#
# Generates index-v1 (string docid) and index-v2 (structured Pubid::Omg)
# in a single pass over data/*.yaml, then compresses each into a sibling
# index*.zip.

require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "relaton/index"
require "relaton/bib"
require "omg_fetcher"

INDEX_V1 = "index-v1.yaml"
INDEX_V2 = "index-v2.yaml"

# Crawl the catalog into data/ first, then index what was written.
store = OmgFetcher::YamlStore.new("data")
written = OmgFetcher::Build.run(store: store)
warn "crawled #{written} documents" unless written.zero?

OmgFetcher::Indexer.build(
  data_dir: "data",
  index_file: INDEX_V1,
  index_v2_file: INDEX_V2,
)
OmgFetcher::Indexer.zip(INDEX_V1, INDEX_V2)
