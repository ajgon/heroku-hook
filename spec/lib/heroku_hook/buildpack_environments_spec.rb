require 'spec_helper'

RSpec.describe 'Buildpack environments' do
  it 'php' do
    HerokuHook::Config.load
    HerokuHook::Config.project_name = 'bare'

    expect(HerokuHook::BuildpackEnvironments.php).to eq(
      'HOME' => '/opt/apps/bare/_app',
      'LD_LIBRARY_PATH' => '/opt/apps/bare/_app/.heroku/php/lib'
    )
  end
end
