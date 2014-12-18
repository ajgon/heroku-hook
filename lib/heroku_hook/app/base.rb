module HerokuHook
  module App
    # Base class which provides global methods for all subclasess
    class Base
      attr_reader :app_path, :cache_path, :env_path

      def initialize(receiver, config)
        @receiver, @config, @output, @success = receiver, config, '', false
        %w(app cache env).each do |dir|
          instance_variable_set("@#{dir}_path",
                                File.join(@config.projects_base_path, @receiver.name, @config.dirs.send(dir)))
        end
      end

      def command(name, language)
        File.join(@config.buildpacks_path, "heroku-buildpack-#{language}", 'bin', name) +
          ' ' + @app_path + ' ' + @cache_path + ' ' + @env_path
      end
    end
  end
end
