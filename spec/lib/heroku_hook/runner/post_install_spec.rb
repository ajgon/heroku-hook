require 'spec_helper'
include BuildHelper

RSpec.describe 'PostInstall' do
  prepare_build_environment
  let(:post_install) { HerokuHook::Runner::PostInstall.new }

  it 'should run postinstall script' do
    test_file = '/tmp/test-lorem-ipsum-734'
    post_install.run('test')

    expect(File.exist?(test_file)).to be_truthy
    expect(File.read(test_file)).to eq "test123\n"
  end
end
