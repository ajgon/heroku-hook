require 'json'
require 'yaml'

module HerokuHook
  # Storage for all configuration parameters
  # :reek:ClassVariable
  # rubocop:disable Style/ClassVars
  class Config
    @@config = {}

    def self.load(path = nil)
      @@config = merge_with_defaults(
        YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config', 'heroku-hook.yml')),
        File.exist?(path.to_s) ? YAML.load_file(path) : {}
      )
      self
    end

    def self.project_name=(name)
      @@project_name = name
    end

    def self.project_name
      @@project_name
    end

    def self.method_missing(name, value = nil)
      name = name.to_s.sub(/=$/, '')
      @@config[name] = value if value
      @@config[name]
    end

    def self.recursive_merge(to, what)
      to.merge(what) do |_key, old, new|
        old.class == Hash ? recursive_merge(old, new) : new
      end
    end

    def self.merge_with_defaults(defaults, extra)
      JSON.parse(recursive_merge(defaults, extra).to_json, object_class: OpenStructExtended)
    end
  end
  # rubocop:enable Style/ClassVars
end
