require 'spec_helper'

RSpec.describe 'Builder' do
  let(:bare_repo_path) { File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git') }
  let(:config_path) { File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml') }
  let(:target_path) { File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox') }
  let(:buildpacks_path) { File.join(RSpec.configuration.fixture_path, 'buildpacks') }

  it 'should build proper Ruby application' do
    receiver = HerokuHook::Receiver.new(bare_repo_path)
    config = HerokuHook::Config.new(config_path)
    config.projects_base_path = target_path
    config.buildpacks_path = buildpacks_path
    builder = HerokuHook::App::Builder.new(receiver, config)

    expect { builder.run }.to output("\e[1GFetching repository, done.\n\e[1G-----> Ruby app detected\n").to_stdout
  end
end
