require 'English'

module HerokuHook
  module App
    # Detects app type in project dir using heroku buildpacks matchers
    class Detector < HerokuHook::App::Base
      def run
        check
        build_output
        HerokuHook::Display.outln(@output)
        @success
      end

      private

      def build_output
        if @success
          @output = "-----> #{@output.strip} app detected"
        else
          @output = " !     Push rejected, no #{@config.stack.capitalize}-supported app detected"
        end
      end

      def check
        @config.buildpacks_order.each do |language|
          @output, @success = [`#{command('detect', language)}`, $CHILD_STATUS.success?]
          break if @success
        end
        [@output, @success]
      end
    end
  end
end
