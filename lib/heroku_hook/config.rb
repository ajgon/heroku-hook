require 'json'
require 'yaml'

module HerokuHook
  # Storage for all configuration parameters
  class Config
    def initialize(path = nil)
      config = YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config', 'heroku-hook.yml'))
      @config = JSON.parse((path ? config.merge(YAML.load_file(path)) : config).to_json, object_class: OpenStruct)
    end

    def self.load(path)
      new(path)
    end

    def method_missing(name, value = nil)
      name = name.to_s
      @config[name.sub(/=$/, '')] = value if value
      @config[name]
    end
  end
end
