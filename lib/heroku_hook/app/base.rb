require 'open3'

module HerokuHook
  module App
    # Base class which provides global methods for all subclasess
    class Base
      attr_reader :app_path, :cache_path, :env_path

      def initialize(receiver, config)
        @receiver, @config, @output, @success = receiver, config, '', false
        %w(app cache env).each do |dir|
          instance_variable_set("@#{dir}_path",
                                File.join(@config.project.base_path, @receiver.name, @config.dirs.send(dir)))
        end
      end

      def command(name, language)
        File.join(@config.buildpacks.path, "heroku-buildpack-#{language}", 'bin', name) +
          ' ' + @app_path + ' ' + @cache_path + ' ' + @env_path
      end

      def run_with_envs(envs, cmd, opts = { rawout: true })
        Open3.popen3(envs, cmd) do |_stdin, stdout, stderr, thread|
          HerokuHook::Displayer.pass_stream stdout, $stdout, opts
          HerokuHook::Displayer.pass_stream stderr, $stderr, opts
          @success = thread.value.success?
        end
      end
    end
  end
end
