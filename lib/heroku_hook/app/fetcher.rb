require 'git'
module HerokuHook
  module App
    # Fetches repo from receiver path and prepares it for buildpacks
    class Fetcher < HerokuHook::App::Base
      def prepare
        [@app_path, @cache_path, @env_path].each do |path|
          FileUtils.rm_rf(path) if path == @app_path
          FileUtils.mkdir_p(path)
        end
      end

      def clone
        Git.export(Receiver.repo_path, @app_path)
      end

      def run
        HerokuHook::Displayer.out 'Fetching repository, '
        prepare
        clone
        HerokuHook::Displayer.raw_outln 'done.'
        [nil, true]
      end
    end
  end
end
