require 'yaml'
require 'open3'

module HerokuHook
  module App
    # Sets up foreman, nginx and supervisord
    class Releaser < HerokuHook::App::Base
      attr_reader :release_config

      def run(language)
        port = HerokuHook::PortHandler.new(@config).fetch @receiver.name
        build_release_config(language)
        build_configurations(port)
        [nil, true]
      end

      def build_configurations(port)
        build_procfile
        build_nginx_config(port)
        build_supervisord_config(port)
      end

      def build_release_config(language)
        out = `#{command('release', language)}`
        @release_config = YAML.load(out)
      end

      def build_procfile
        return if File.exist?(procfile_path)
        File.open(procfile_path, 'w') do |procfile|
          prepare_procfile procfile
        end
      end

      def build_nginx_config(port)
        run_foreman_export('nginx', port)
      end

      def build_supervisord_config(port)
        run_foreman_export('supervisord', port)
      end

      private

      def run_foreman_export(name, port)
        config_path = @config.send("#{name}_configs_path")
        cmd = "foreman export #{name} #{config_path} -p #{port} -u #{@config.processes_owner} " \
              "-f #{procfile_path} -a #{@receiver.name}"
        Open3.popen3({ 'BASE_DOMAIN' => @config.base_domain }, cmd) { |_stdin, _stdout, _stderr, thread| thread.join }
      end

      def procfile_path
        File.join(@app_path, 'Procfile')
      end

      def prepare_procfile(handler)
        %w(web).each do |item|
          handler.write "#{item}: #{release_config['default_process_types'][item]}\n"
        end
      end
    end
  end
end
