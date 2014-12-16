module HerokuHook
  module App
    # Base class which provides global methods for all subclasess
    class Base
      def initialize(receiver, config)
        @receiver, @config = receiver, config
        %w(app cache env).each do |dir|
          instance_variable_set("@#{dir}_path",
                                File.join(@config.projects_base_path, @receiver.name, @config.dirs.send(dir)))
        end
      end
    end
  end
end
