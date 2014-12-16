require 'spec_helper'

RSpec.describe 'Compiler' do
  let(:bare_repo_path) { File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git') }
  let(:config_path) { File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml') }
  let(:target_path) { File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox') }
  let(:buildpacks_path) { File.join(RSpec.configuration.fixture_path, 'buildpacks') }

  it 'should build proper Ruby application' do
    receiver = HerokuHook::Receiver.new(bare_repo_path)
    config = HerokuHook::Config.new(config_path)
    config.projects_base_path = target_path
    config.buildpacks_path = buildpacks_path
    compiler = HerokuHook::App::Compiler.new(receiver, config)

    expect { compiler.run('ruby') }.to output(
      "\e[1G-----> Compiling Ruby/Rails\n" \
      "\e[1G-----> Using Ruby version: ruby-2.1.5\n" \
      "\e[1G-----> Installing dependencies using 1.6.3\n" \
      "\e[1G       Running: bundle install --without development:test --path vendor/bundle " \
                   "--binstubs vendor/bundle/bin -j4 --deployment\n" \
      "\e[1G       Installing hello-world 1.2.0\n"
    ).to_stdout
  end
end
