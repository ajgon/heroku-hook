# Helper to build release environment
module BuildHelper
  def prepare_build_environment
    prepare_build_receiver
    prepare_build_config
  end

  def prepare_build_receiver
    let(:build_receiver) { HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git')) }
  end

  def prepare_build_config
    let(:build_config) do
      config = HerokuHook::Config.new(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
      assign_build_config_variables(config)
    end
  end

  def assign_build_config_variables(build_config)
    build_config.projects_base_path, build_config.buildpacks_path = build_projects_base_path, build_buildpacks_path
    build_config.nginx_configs_path = build_projects_base_path
    build_config.supervisord_configs_path = build_projects_base_path
    build_config.ports_directory = build_projects_base_path
    build_config
  end

  # :reek:UtilityFunction
  def build_projects_base_path
    File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox')
  end

  # :reek:UtilityFunction
  def build_buildpacks_path
    File.join(RSpec.configuration.fixture_path, 'buildpacks')
  end
end
