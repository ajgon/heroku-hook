require 'open3'

module HerokuHook
  module App
    # Base class which provides global methods for all subclasess
    class Base
      attr_reader :app_path, :cache_path, :env_path

      def initialize
        @output, @success = '', false
        %w(app cache env).each do |dir|
          instance_variable_set("@#{dir}_path",
                                File.join(Config.project.base_path, Config.project_name, Config.dirs.send(dir)))
        end
      end

      def command(name, language)
        File.join(Config.buildpacks.path, "heroku-buildpack-#{language}", 'bin', name) +
          ' ' + @app_path + ' ' + @cache_path + ' ' + @env_path
      end

      def run_with_envs(envs, cmd, opts = {})
        @success = Spawner.spawn(envs, cmd, opts)
      end
    end
  end
end
