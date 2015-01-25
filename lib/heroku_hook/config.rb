require 'json'
require 'yaml'

module HerokuHook
  # Storage for all configuration parameters
  # rubocop:disable Style/ModuleFunction
  module Config
    extend self
    attr_accessor :project_name, :repo_path
    @config = {}

    def load(path = nil)
      default_config = recursive_merge(
        YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config', 'heroku-hook.yml')),
        File.exist?('/etc/heroku-hook.yml') ? YAML.load_file('/etc/heroku-hook.yml') : {}
      )
      @config = merge_with_defaults(default_config, File.exist?(path.to_s) ? YAML.load_file(path) : {})
    end

    def method_missing(name, value = nil)
      name = name.to_s.sub(/=$/, '')
      @config[name] = value if value
      @config[name]
    end

    def recursive_merge(to, what)
      to.merge(what) do |_key, old, new|
        old.class == Hash ? recursive_merge(old, new) : new
      end
    end

    def merge_with_defaults(defaults, extra)
      JSON.parse(recursive_merge(defaults, extra).to_json, object_class: OpenStructExtended)
    end
  end
  # rubocop:enable Style/ModuleFunction
end
