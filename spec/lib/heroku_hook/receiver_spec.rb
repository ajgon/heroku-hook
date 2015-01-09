require 'spec_helper'

RSpec.describe 'Receiver' do
  before(:all) do
    normal_path = File.join(RSpec.configuration.fixture_path, 'repos', 'normal')
    FileUtils.mv File.join(normal_path, '.git-tpl'), File.join(normal_path, '.git')
  end

  after(:all) do
    normal_path = File.join(RSpec.configuration.fixture_path, 'repos', 'normal')
    FileUtils.mv File.join(normal_path, '.git'), File.join(normal_path, '.git-tpl')
  end

  context 'repos' do
    let(:bare) { HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git')) }
    let(:normal) { HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'normal')) }

    it 'should check if repository is bare' do
      expect { HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path)) }
        .to raise_error(Git::GitExecuteError)
      expect(bare.bare?).to be_truthy
      expect(normal.bare?).to be_falsey
    end
  end
end
