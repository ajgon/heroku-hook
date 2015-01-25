# Helper to build release environment
module BuildHelper
  def prepare_build_environment
    prepare_build_receiver
    prepare_build_config
  end

  # :reek:UtilityFunction
  # :reek:FeatureEnvy
  def create_port_store(name, port)
    File.open(File.join(HerokuHook::Config.ports.path, "#{name}.port"), 'w') { |file| file.write(port.to_s) }
  end

  # :reek:UtilityFunction
  def prepare_build_receiver
    HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git'))
  end

  def prepare_build_config
    HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    assign_build_config_variables
    assign_project_config_variables
  end

  def assign_build_config_variables
    HerokuHook::Config.buildpacks.path = build_buildpacks_path
    HerokuHook::Config.nginx.configs_path = build_projects_base_path
    HerokuHook::Config.supervisord.configs_path = build_projects_base_path
    HerokuHook::Config.ports.path = build_projects_base_path
  end

  def assign_project_config_variables
    project = HerokuHook::Config.project
    project.base_path = build_projects_base_path
    project.base_log_path = build_projects_base_path
  end

  def rack_env
    default_env('RACK_ENV', 'production')
  end

  def rails_env
    default_env('RAILS_ENV', 'production')
  end

  # :reek:UtilityFunction
  def build_projects_base_path
    File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox')
  end

  # :reek:UtilityFunction
  def build_buildpacks_path
    File.join(RSpec.configuration.fixture_path, 'buildpacks')
  end

  # :reek:UtilityFunction
  def default_env(name, default)
    (env_value = ENV[name].to_s).empty? ? default : env_value
  end
end
