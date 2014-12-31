require 'json'
require 'yaml'

module HerokuHook
  # Storage for all configuration parameters
  class Config
    def self.recursive_merge(to, what)
      to.merge(what) do |_key, old, new|
        old.class == Hash ? recursive_merge(old, new) : new
      end
    end

    def initialize(path = nil)
      @config = merge_with_defaults(
        YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config', 'heroku-hook.yml')),
        File.exist?(path.to_s) ? YAML.load_file(path) : {}
      )
    end

    def self.load(path)
      new(path)
    end

    def method_missing(name, value = nil)
      name = name.to_s.sub(/=$/, '')
      @config[name] = value if value
      @config[name]
    end

    private

    def merge_with_defaults(defaults, extra)
      JSON.parse(self.class.recursive_merge(defaults, extra).to_json, object_class: OpenStructExtended)
    end
  end
end
