require 'English'

module HerokuHook
  module App
    # Detects app type in project dir using heroku buildpacks matchers
    class Detector < HerokuHook::App::Base
      def run
        language = detect_language
        build_output
        HerokuHook::Display.outln(@output)
        [language, @success]
      end

      private

      def build_output
        if @success
          @output = "-----> #{@output.strip} app detected"
        else
          @output = " !     Push rejected, no #{@config.stack.capitalize}-supported app detected"
        end
      end

      def detect_language
        @config.buildpacks_order.detect do |language|
          @output, @success = [`#{command('detect', language)}`, $CHILD_STATUS.success?]
          @success
        end
      end
    end
  end
end
