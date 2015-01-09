require 'fileutils'

module HerokuHook
  module Runner
    # Class for cleaning up after successful deploy
    class Cleaner < HerokuHook::Runner::Base
      def run(app_path = File.join('/', 'app'))
        app_dir = File.join(app_path, '.')
        FileUtils.rm_rf(app_dir, secure: true) if File.exist?(app_dir)
        [nil, @success = true]
      end
    end
  end
end
