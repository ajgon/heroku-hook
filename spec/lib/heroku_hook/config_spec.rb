require 'spec_helper'

RSpec.describe 'Config' do
  let(:config_default) { HerokuHook::Config.new }
  let(:config) { HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml')) }

  it 'should keep default options' do
    expect(config_default.projects_base_path).to eq '/opt/apps'
    expect(config_default.stack).to eq 'heroku'
    expect(config_default.dirs.app).to eq '_app'
    expect(config_default.dirs.cache).to eq '_cache'
    expect(config_default.dirs.env).to eq '_env'
  end

  it 'should load config properly' do
    expect(config.projects_base_path).to eq '/path/to/applications'
    expect(config.stack).to eq 'heroku'
  end

  it 'should allow to overwrite config param manually' do
    config.stack = 'test'
    expect(config.stack).to eq 'test'
  end
end
