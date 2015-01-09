require 'spec_helper'

RSpec.describe 'Fetcher' do
  before(:all) do
    @target_path = File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox')
    HerokuHook::Receiver.handle(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git'))
    HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    HerokuHook::Config.project.base_path = @target_path
    @fetcher = HerokuHook::Runner::Fetcher.new
  end

  it 'should prepare repository in clean directory' do
    @fetcher.prepare

    expect(File.exist?(@fetcher.app_path)).to be_truthy
    expect(File.exist?(@fetcher.cache_path)).to be_truthy
    expect(File.exist?(@fetcher.env_path)).to be_truthy
  end

  it 'should remove _app contents but leave _cache and _env during preparation' do
    FileUtils.mkdir_p(File.join(@fetcher.app_path, 'app-to-be-removed'))
    FileUtils.mkdir_p(File.join(@fetcher.cache_path, 'cache-to-be-preserved'))
    FileUtils.mkdir_p(File.join(@fetcher.env_path, 'env-to-be-preserved'))

    @fetcher.prepare

    expect(File.exist?(File.join(@fetcher.app_path, 'app-to-be-removed'))).to be_falsey
    expect(File.exist?(File.join(@fetcher.cache_path, 'cache-to-be-preserved'))).to be_truthy
    expect(File.exist?(File.join(@fetcher.env_path, 'env-to-be-preserved'))).to be_truthy
  end

  it 'should wipe the directory and fetch clean application' do
    FileUtils.mkdir_p(File.join(@target_path, HerokuHook::Config.project_name, '_app', 'to-be-removed'))
    File.open(File.join(@target_path, HerokuHook::Config.project_name, '_app', 'to-be-removed-as-well'), 'w') do |file|
      file.write 'remove'
    end

    success = false
    expect { success = @fetcher.run }.to output("\e[1GFetching repository, done.\n").to_stdout

    expect(success).to be_truthy
    expect(File.exist?(File.join(@fetcher.app_path, 'to-be-removed'))).to be_falsey
    expect(File.exist?(File.join(@fetcher.app_path, 'to-be-removed-as-well'))).to be_falsey
    expect(File.exist?(File.join(@fetcher.app_path, 'Gemfile'))).to be_truthy
  end
end
