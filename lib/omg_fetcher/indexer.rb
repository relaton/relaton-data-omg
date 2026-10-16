# frozen_string_literal: true

require "relaton/index"
require "relaton/bib"
require "relaton/omg"
require "zip"

module OmgFetcher
  # Builds the docid → file-path index over data/*.yaml using
  # relaton-index, and compresses each index YAML into a sibling
  # index*.zip (the layout the released consumers expect). Mirrors the
  # Adobe fetcher's Indexer; no type-specific logic.
  #
  # Two index flavours, built in a single pass:
  #   * index-v1.yaml  — flat string docid → file
  #   * index-v2.yaml  — structured Pubid::Omg identifier → file
  module Indexer
    module_function

    def build(data_dir:, index_file:, index_v2_file: nil)
      idx = Relaton::Index.find_or_create(
        :omg, file: File.basename(index_file), pubid_class: ::Pubid::Omg::Identifier
      )
      idx2 = index_v2_file && Relaton::Index.find_or_create(
        :omg, file: File.basename(index_v2_file), pubid_class: ::Pubid::Omg::Identifier
      )
      base = File.dirname(File.expand_path(index_file))

      Dir[File.join(data_dir, "*.yaml")].sort.each do |f|
        item = Relaton::Omg::Item.from_yaml(File.read(f, encoding: "UTF-8"))
        docid = item.docidentifier.find(&:primary) || item.docidentifier.first
        unless docid
          warn "Error processing #{f}: no docidentifier"
          next
        end
        rel = File.expand_path(f).delete_prefix("#{base}/")
        idx.add_or_update docid.content, rel
        # The printed citation form (OMG AEP 1.0), not item.id — the model's
        # computed id (OMGAEP10) is not pubid-parseable and left v2 empty.
        add_pubid(idx2, docid.content, rel) if idx2
      rescue StandardError => e
        warn "Error processing #{f}: #{e.message}"
      end

      idx.save
      idx2&.save
      [idx, idx2]
    end

    # The v2 row keys on the structural id (item.id) — the citation form a
    # spec version page prints can carry decoration pubid won't parse; an
    # unparseable id is warned about and left out of index-v2, not fatal.
    def add_pubid(idx, id, rel)
      pubid = ::Pubid::Omg::Identifier.parse(id.to_s)
      idx.add_or_update pubid, rel
    rescue Pubid::Errors::Error => e
      warn "Error indexing #{id}: #{e.message}"
    end

    def zip(*index_files)
      index_files.compact.each do |yaml|
        zip_path = "#{yaml.chomp('.yaml')}.zip"
        File.delete(zip_path) if File.exist?(zip_path)
        Zip::File.open(zip_path, create: true) do |archive|
          archive.add(File.basename(yaml), yaml)
        end
      end
    end
  end
end
