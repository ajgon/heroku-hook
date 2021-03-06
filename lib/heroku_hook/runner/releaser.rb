require 'yaml'
require 'open3'

module HerokuHook
  module Runner
    # Sets up foreman, nginx and supervisord
    class Releaser < HerokuHook::Runner::Base
      attr_reader :release_config

      def initialize
        super
        @port = HerokuHook::PortHandler.new.fetch project_name
      end

      def run(language)
        build_release_config(language)
        prepare_release_variables(language)
        build_configurations
        create_directories
        [nil, true]
      end

      def build_configurations
        build_procfile
        build_nginx_config
        build_supervisord_config
      end

      def create_directories
        FileUtils.mkdir_p(log_path)
      end

      def prepare_release_variables(language)
        env_handler = HerokuHook::EnvHandler.new('HOME' => @app_path)
        env_handler.load_file(File.join(@app_path, '.profile.d', "#{language}.sh"))
        env_handler.add_buildpack_environments(language)
        File.open(default_env_path, 'w') { |env_file| env_file.write(env_handler.to_s) }
      end

      def build_release_config(language)
        @release_config = YAML.load(`#{command('release', language)}`)
      end

      def build_procfile
        File.open(procfile_path, 'w') do |procfile|
          prepare_procfile procfile
        end unless File.exist?(procfile_path)
        insert_envs_into_procfile(procfile_path)
      end

      def build_nginx_config
        run_foreman_export('nginx')
      end

      def build_supervisord_config
        run_foreman_export('supervisord')
        path = File.join(Config.supervisord.configs_path, project_name + '.conf')
        replacement = File.read(path).gsub(/^command=/, "command=heroku-hook run-for-#{project_name} ")
        File.open(path, 'w') { |file| file.write(replacement) }
      end

      private

      def project_name
        Config.project_name
      end

      def run_foreman_export(name)
        cmd = "foreman export #{name} #{Config.send(name).send(:configs_path)} -p #{@port} " \
              "-u #{Config.processes_owner} -f #{procfile_path} -a #{project_name} -e #{all_env_paths} -l #{log_path}"
        Open3.popen3(defaults_for_foreman.merge(all_envs_with_port_handler.envs), cmd) do |_in, _out, _err, thread|
          thread.join
        end
      end

      def log_path
        File.join(Config.project.base_log_path, project_name)
      end

      def procfile_path
        File.join(@app_path, 'Procfile')
      end

      def prepare_procfile(handler)
        %w(web).each do |item|
          item_line = release_config['default_process_types'][item]
          handler.write "#{item}: #{item_line}\n"
        end
      end

      def insert_envs_into_procfile(path)
        procfile_data = all_envs_with_port_handler.expand_string(File.read(path))
        File.open(path, 'w') do |procfile|
          procfile.write(procfile_data)
        end
      end

      def ssl_certs_and_keys_file_basename
        File.join(Config.nginx.ssl_certs_and_keys_path, "#{project_name}")
      end

      def defaults_for_foreman
        {
          'BASE_DOMAIN' => Config.project.base_domain,
          'SSL_CERT_PATH' => ssl_certs_and_keys_file_basename + '.crt',
          'SSL_KEY_PATH' => ssl_certs_and_keys_file_basename + '.key'
        }
      end

      def all_envs_with_port_handler
        env_handler = HerokuHook::EnvHandler.new('HOME' => @app_path)
        env_handler.load_files(Dir.glob(File.join(@env_path, '*.env')))
        env_handler.add_to_envs('PORT' => @port.to_s)
        env_handler
      end

      def default_env_path
        File.join(@env_path, '_default.env')
      end

      def all_env_paths(separator = ',')
        Dir.glob(File.join(@env_path, '*')).join(separator)
      end
    end
  end
end
