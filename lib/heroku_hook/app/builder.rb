module HerokuHook
  module App
    # Builds app from start to finish
    class Builder < HerokuHook::App::Base
      def initialize(receiver, config)
        @fetcher = HerokuHook::App::Fetcher.new(receiver, config)
        @detector = HerokuHook::App::Detector.new(receiver, config)

        super(receiver, config)
      end

      def run
        [@fetcher, @detector].all?(&:run)
      end
    end
  end
end