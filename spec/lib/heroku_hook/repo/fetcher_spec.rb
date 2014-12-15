require 'spec_helper'

RSpec.describe 'Fetcher' do
  let(:repo_path) do
    File.join(RSpec.configuration.fixture_path, '..', 'fs-sandbox')
  end

  let(:receiver) do
    HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git'))
  end

  let(:repo) do
    config = HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    config.projects_base_path = repo_path
    HerokuHook::Repo::Fetcher.new(receiver, config)
  end

  it 'should prepare repository in clean directory' do
    repo.prepare

    expect(File.exist?(repo.app_path)).to be_truthy
    expect(File.exist?(repo.cache_path)).to be_truthy
    expect(File.exist?(repo.env_path)).to be_truthy
  end

  it 'should remove _app contents but leave _cache and _env during preparation' do
    FileUtils.mkdir_p(File.join(repo.app_path, 'app-to-be-removed'))
    FileUtils.mkdir_p(File.join(repo.cache_path, 'cache-to-be-preserved'))
    FileUtils.mkdir_p(File.join(repo.env_path, 'env-to-be-preserved'))

    repo.prepare

    expect(File.exist?(File.join(repo.app_path, 'app-to-be-removed'))).to be_falsey
    expect(File.exist?(File.join(repo.cache_path, 'cache-to-be-preserved'))).to be_truthy
    expect(File.exist?(File.join(repo.env_path, 'env-to-be-preserved'))).to be_truthy
  end

  it 'should wipe the directory and fetch clean application' do
    FileUtils.mkdir_p(File.join(repo_path, receiver.name, '_app', 'to-be-removed'))
    File.open(File.join(repo_path, receiver.name, '_app', 'to-be-removed-as-well'), 'w') { |f| f.write 'remove' }

    repo.build

    expect(File.exist?(File.join(repo.app_path, 'to-be-removed'))).to be_falsey
    expect(File.exist?(File.join(repo.app_path, 'to-be-removed-as-well'))).to be_falsey
    expect(File.exist?(File.join(repo.app_path, 'app'))).to be_truthy
  end
end
