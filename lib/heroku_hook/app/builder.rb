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
        # @releaser.run(language)
      end
    end
  end
end
