require 'open3'

module HerokuHook
  module App
    # Builds app from start to finish
    class Builder < HerokuHook::App::Base
      def initialize
        @fetcher, @detector = Fetcher.new, Detector.new
        @compiler, @releaser = Compiler.new, Releaser.new
        @cleaner = Cleaner.new
        super
      end

      def run
        @fetcher.run
        language, _success = @detector.run
        @compiler.run(language)
        @releaser.run(language)
        @cleaner.run
      end

      def run_command(cmd, context = nil)
        context = run_context(context)
        run_with_envs({ 'PATH' => "#{context}:#{ENV['PATH']}" }, cmd, context: context)
      end

      private

      def run_context(context)
        return @app_path if context.to_s == ''
        File.expand_path(File.join(Config.project.base_path, context, Config.dirs.app))
      end
    end
  end
end
