require 'spec_helper'

RSpec.describe 'Config' do
  let(:config_default) { HerokuHook::Config.new }
  let(:config) { HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml')) }

  it 'should merge hash deeply' do
    merged = HerokuHook::Config.recursive_merge({ num: { '1' => 'one', '2' => 'two' } }, num: { '3' => 'three' })
    merged2 = HerokuHook::Config.recursive_merge({ num: { '1' => 'one', '2' => 'two' } }, num: { '1' => 'three' })
    merged3 = HerokuHook::Config.recursive_merge({ num: { '1' => 'one', '2' => 'two' } }, {})

    expect(merged).to eq(num: { '1' => 'one', '2' => 'two', '3' => 'three' })
    expect(merged2).to eq(num: { '1' => 'one', '2' => 'two', '1' => 'three' })
    expect(merged3).to eq(num: { '1' => 'one', '2' => 'two' })
  end

  it 'should keep default options' do
    expect(config_default.project.base_path).to eq '/opt/apps'
    expect(config_default.stack).to eq 'cedar'
    expect(config_default.dirs.app).to eq '_app'
    expect(config_default.dirs.cache).to eq '_cache'
    expect(config_default.dirs.env).to eq '_env'
  end

  it 'should load config properly' do
    expect(config.project.base_path).to eq '/path/to/applications'
    expect(config.stack).to eq 'cedar'
  end

  it 'should allow to overwrite config param manually' do
    config.stack = 'test'
    expect(config.stack).to eq 'test'
  end
end
