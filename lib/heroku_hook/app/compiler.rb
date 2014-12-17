require 'git'
require 'English'
require 'open3'

module HerokuHook
  module App
    # Runs buildback hook and builds an application
    class Compiler < HerokuHook::App::Base
      def run(language)
        Open3.popen3({ 'STACK' => @config.stack }, command('compile', language)) do |_stdin, stdout, _stderr, thread|
          build_thread_for stdout
          thread.join
        end
      end

      private

      def build_thread_for(std)
        std.sync = true

        Thread.new do
          process_output_from(std)
        end
      end

      # rubocop:disable Lint/AssignmentInCondition
      def process_output_from(stdout)
        while line = stdout.gets
          @output += line
          HerokuHook::Display.outln(line)
          STDOUT.flush
        end
      end
      # rubocop:enable Lint/AssignmentInCondition
    end
  end
end
