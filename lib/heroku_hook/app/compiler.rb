require 'git'
module HerokuHook
  module App
    # Runs buildback hook and builds an application
    class Compiler < HerokuHook::App::Base
      def run(language)
        IO.popen(command('compile', language)) { |stdout| process_output_from stdout }
        @success = true
      rescue
        @success = false
      end

      private

      def process_output_from(stdout)
        stdout.each do |line|
          @output += line
          HerokuHook::Display.outln(line)
        end
      end
    end
  end
end
