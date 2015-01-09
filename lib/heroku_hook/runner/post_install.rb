require 'fileutils'

module HerokuHook
  module Runner
    # Class for cleaning up after successful deploy
    class PostInstall < HerokuHook::Runner::Base
      def run(language)
        script_path = File.expand_path(
          File.join([File.dirname(__FILE__), '..', '..', '..', 'scripts', "#{language}.postinstall"])
        )
        [nil, File.exist?(script_path) ? system("#{script_path} #{app_path}") : true]
      end
    end
  end
end
