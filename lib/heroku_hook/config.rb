require 'json'
require 'yaml'

module HerokuHook
  # Storage for all configuration parameters
  class Config
    def initialize(path = nil)
      config = YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config', 'heroku-hook.yml'))
      @config = JSON.parse(
        (File.exist?(path.to_s) ? config.merge(YAML.load_file(path)) : config).to_json, object_class: OpenStructExtended
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
  end
end
