# frozen_string_literal: true

require "relaton/bib"
require "relaton/omg"

# OmgFetcher crawls the OMG Specifications Catalog (https://www.omg.org/spec)
# into Relaton YAML files under data/ — the machine index the relaton-data-omg
# Pages site publishes (relaton#206 shape: manifest + shards served by the
# shared data-deploy workflow).
#
# The OMG gem's Scraper (Relaton::Omg::Scraper) owns all per-page parsing;
# this fetcher only enumerates the catalog and persists what the Scraper
# builds.
module OmgFetcher
  autoload :Catalog,   "omg_fetcher/catalog"
  autoload :Http,      "omg_fetcher/http"
  autoload :Build,     "omg_fetcher/build"
  autoload :YamlStore, "omg_fetcher/yaml_store"
  autoload :Indexer,   "omg_fetcher/indexer"
end
