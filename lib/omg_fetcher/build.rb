# frozen_string_literal: true

module OmgFetcher
  # Crawls the catalog into data/*.yaml, one file per spec version. All
  # parsing is delegated to Relaton::Omg::Scraper — a reference it cannot
  # parse (or a page that fails to build an item) is warned about and
  # skipped, never fatal to the crawl.
  module Build
    module_function

    # @param store [YamlStore]
    # @param acronyms [Array<String>, nil] subset for a partial crawl
    # @return [Integer] the number of files written
    def run(store:, acronyms: nil)
      written = 0
      (acronyms || Catalog.acronyms).each do |acronym|
        Catalog.versions(acronym).each do |version|
          ref = "OMG #{acronym} #{version}"
          item = Relaton::Omg::Scraper.scrape_page(ref)
          next unless item

          store.write(slug(acronym, version), item.to_yaml)
          written += 1
        rescue StandardError => e
          warn "Error processing #{ref}: #{e.message}"
        end
      end
      written
    end

    def slug(acronym, version)
      "#{acronym.downcase}-#{version.downcase.tr(' /', '-')}"
    end
  end
end
