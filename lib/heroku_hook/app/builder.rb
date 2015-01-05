require 'open3'

module HerokuHook
  module App
    # Builds app from start to finish
    class Builder < HerokuHook::App::Base
      def initialize(receiver, config)
        @fetcher = HerokuHook::App::Fetcher.new(receiver, config)
        @detector = HerokuHook::App::Detector.new(receiver, config)
        @compiler = HerokuHook::App::Compiler.new(receiver, config)
        @releaser = HerokuHook::App::Releaser.new(receiver, config)
        super(receiver, config)
      end

      def run
        @fetcher.run
        language, _success = @detector.run
        @compiler.run(language)
        @releaser.run(language)
      end

      def run_command(cmd, context = nil)
        context = run_context(context)
        run_with_envs({ 'PATH' => "#{context}:#{ENV['PATH']}" }, cmd, context: context)
      end

      private

      def run_context(context)
        return @app_path if context.to_s == ''
        File.expand_path(File.join(@config.project.base_path, context, @config.dirs.app))
      end
    end
  end
end
