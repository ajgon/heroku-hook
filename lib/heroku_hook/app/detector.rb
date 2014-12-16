require 'English'

module HerokuHook
  module App
    # Detects app type in project dir using heroku buildpacks matchers
    class Detector < HerokuHook::App::Base
      attr_reader :output, :success

      def initialize(receiver, config)
        @output, @success = 'no', false
        super(receiver, config)
      end

      def run
        @config.buildpacks_order.each do |name|
          @output, @success = ["-----> #{`#{command(name, @app_path)}`.strip} app detected", $CHILD_STATUS.success?]
          break if @success
        end
        @output = " !     Push rejected, no #{@config.stack.upcase}-supported app detected" unless @success
      end

      def command(language, app_path)
        File.join(@config.buildpacks_path, "heroku-buildpack-#{language}", 'bin', 'detect') + ' ' + app_path
      end
    end
  end
end
