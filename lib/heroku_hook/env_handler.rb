require 'dotenv/parser'

module HerokuHook
  # Class used to handle environment variables
  class EnvHandler
    attr_reader :envs

    def self.overwrite_env_with(env)
      env.each do |name, _value|
        ENV[name] = env[name]
      end
    end

    def self.handle_defaults_from_parsed_hash(envs)
      fixed = envs.map do |name, value|
        parts = value.split(':-', 2)
        [name, parts.size > 1 && parts.first.size == 0 ? parts.last.sub(/\}$/, '') : parts[0]]
      end
      Hash[fixed]
    end

    def initialize(context = {})
      @envs = {}
      @context = context
    end

    def expand_string(str)
      @envs.each do |name, value|
        str.gsub!(/\$\{?#{name}\}?/, value)
      end
      str
    end

    def load_files(env_files)
      env_files.each do |env_file|
        load_file(env_file) if File.exist?(env_file)
      end
    end

    def load_file(path)
      add_to_envs(parse_string(File.read(path)))
    end

    def to_s(separator = "\n")
      @envs.to_a.map { |env| env.join('=') }.join(separator)
    end

    def add_to_envs(envs)
      @envs.merge!(envs)
      envs
    end

    private

    def parse_string(str)
      env, klass = copy_env_hash, self.class
      klass.overwrite_env_with(@context)
      results = klass.handle_defaults_from_parsed_hash(Dotenv::Parser.call(str))
      klass.overwrite_env_with(env)
      results
    end

    def copy_env_hash
      Hash[@context.map { |name, _value| [name, ''] }].merge(ENV.to_hash)
    end
  end
end
