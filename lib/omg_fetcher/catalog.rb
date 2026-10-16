# frozen_string_literal: true

module OmgFetcher
  # Enumerates the OMG Specifications Catalog. The catalog landing page
  # embeds a JSON-LD block whose @imports list every spec's About page —
  # the acronym list, no listing markup to scrape. Each About page links
  # the spec's version pages, whose URL shape is
  # /spec/<ACRONYM>/<VERSION> with the version's spaces as slashes.
  module Catalog
    SPEC_URL = "https://www.omg.org/spec"
    ABOUT_RE = %r{https://www\.omg\.org/spec/([A-Za-z0-9]+)/About-}.freeze
    # The per-version About link (/spec/<ACRO>/<VERSION>/About-<ACRO>, absolute
    # or root-relative) is the one-per-version signal; asset and format links
    # (PDF, XMI, issue-tracker paths) never carry the About tail.
    VERSION_RE = %r{href="(?:https://www\.omg\.org)?/spec/([A-Za-z0-9]+)/([0-9][^"]*)/About-\1"}.freeze

    module_function

    # @return [Array<String>] every spec acronym in the catalog
    def acronyms
      Http.get(SPEC_URL).scan(ABOUT_RE).map { |(a)| a }.uniq.sort
    end

    # @param acronym [String]
    # @return [Array<String>] version query strings ("2.5.1", "2.0 beta 2")
    def versions(acronym)
      body = Http.get("#{SPEC_URL}/#{acronym}/About-#{acronym}")
      body.scan(VERSION_RE).map do |(_, seg)|
        seg.split("/").join(" ")
      end.uniq.sort
    end
  end
end
