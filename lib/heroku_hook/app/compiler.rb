require 'git'
require 'English'

module HerokuHook
  module App
    # Runs buildback hook and builds an application
    class Compiler < HerokuHook::App::Base
      def run(language)
        IO.popen(command('compile', language)) do |io|
          process_output_from io
          @success = $CHILD_STATUS.success?
        end
        @success
      end

      private

      # rubocop:disable Lint/AssignmentInCondition
      def process_output_from(io)
        while line = io.gets
          @output += line
          HerokuHook::Display.outln(line)
        end
      end
      # rubocop:enable Lint/AssignmentInCondition
    end
  end
end
