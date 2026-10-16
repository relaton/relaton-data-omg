# frozen_string_literal: true

require "fileutils"

module OmgFetcher
  # Single place that owns YAML I/O for the data/ directory: encoding,
  # location resolution, idempotency policy, and round-trip serialization
  # via the OMG-flavored Item (the Adobe-fetcher shape).
  class YamlStore
    def initialize(dir)
      @dir = File.expand_path(dir)
      FileUtils.mkdir_p(@dir)
    end

    def write(name, yaml, overwrite: true)
      path = path_for(name)
      return false if File.exist?(path) && !overwrite

      File.write(path, yaml, encoding: "UTF-8")
      true
    end

    def read(name)
      YAML.safe_load(File.read(path_for(name), encoding: "UTF-8"),
                     permitted_classes: [Date, Time],
                     aliases: true)
    end

    def exist?(name)
      File.exist?(path_for(name))
    end

    def each_yaml
      return enum_for(:each_yaml) unless block_given?

      Dir[File.join(@dir, "*.yaml")].sort.each do |path|
        yield File.basename(path, ".yaml"), path
      end
    end

    def path_for(name)
      name = name.to_s.sub(/\.yaml\z/, "")
      File.join(@dir, "#{name}.yaml")
    end
  end
end
