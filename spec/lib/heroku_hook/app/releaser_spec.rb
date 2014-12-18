require 'spec_helper'
include BuildHelper

RSpec.describe 'Releaser' do
  prepare_build_environment
  let(:releaser) { HerokuHook::App::Releaser.new(build_receiver, build_config) }
  let(:fetcher) { HerokuHook::App::Fetcher.new(build_receiver, build_config) }
  let(:procfile_path) { File.join(build_config.projects_base_path, 'bare', '_app', 'Procfile') }
  let(:nginx_configs_path) { File.join(build_config.nginx_configs_path, 'bare.conf') }
  let(:supervisord_configs_path) { File.join(build_config.supervisord_configs_path, 'bare.conf') }
  let(:port) { HerokuHook::Networker.restricted_free_port }

  before(:each) do
    fetcher.run
    releaser.build_release_config('ruby')
  end

  it 'should fetch heroku release config' do
    expect(releaser.release_config).to eq(
      'addons' => ['heroku-postgresql:hobby-dev'],
      'config_vars' => {
        'LANG' => 'en_US.UTF-8',
        'RAILS_ENV' => 'production',
        'RACK_ENV' => 'production'
      },
      'default_process_types' => {
        'rake' => 'bundle exec rake',
        'console' => 'bin/rails console',
        'web' => 'bin/rails server -p $PORT -e $RAILS_ENV',
        'worker' => 'bundle exec rake jobs:work'
      }
    )
  end

  context 'procfile' do
    it 'should be built if none present' do
      releaser.build_procfile

      expect(File.exist?(procfile_path)).to be_truthy
      expect(File.read(procfile_path))
        .to eq "web: bin/rails server -p \$PORT -e \$RAILS_ENV\nworker: bundle exec rake jobs:work\n"
    end

    it 'should keep it as is if available' do
      File.open(procfile_path, 'w') { |handler| handler.write('test') }
      releaser.build_procfile

      expect(File.exist?(procfile_path)).to be_truthy
      expect(File.read(procfile_path))
        .to eq 'test'
    end
  end

  it 'should generate proper nginx config' do
    releaser.build_procfile
    releaser.build_nginx_config(port)

    nginx_config = File.read(nginx_configs_path)

    expect(File.exist?(nginx_configs_path)).to be_truthy

    expect(nginx_config).to match(/^upstream bare \{$/)
    expect(nginx_config).to match(/server localhost:#{port}/)
    expect(nginx_config).to match(%r{access_log /var/log/bare/bare-nginx-access.log})
    expect(nginx_config).to match(%r{error_log  /var/log/bare/bare-nginx-error.log})
    expect(nginx_config).to match(/server_name\s+bare.lvh.me;/)
    expect(nginx_config).to match(%r{root .*/spec/fs-sandbox/bare/_app/public;})
    expect(nginx_config).to match(%r{proxy_pass http://bare;})
  end

  it 'should generate proper supervisord config' do
    releaser.build_procfile
    releaser.build_supervisord_config(port)

    supervisord_config = File.read(supervisord_configs_path)

    expect(File.exist?(supervisord_configs_path)).to be_truthy
    expect(supervisord_config).to match(/^\[program:bare-web-1\]$/)
    expect(supervisord_config).to match(%r{^stdout_logfile=/var/log/bare/web-1.log$})
    expect(supervisord_config).to match(%r{^stderr_logfile=/var/log/bare/web-1.error.log$})
    expect(supervisord_config).to match(/^user=web$/)
    expect(supervisord_config).to match(%r{^directory=.*/spec/fs-sandbox/bare/_app$})
    expect(supervisord_config).to match(/^environment=PORT="#{port}"$/)
    expect(supervisord_config).to match(/programs=bare-web-1,bare-worker-1/)
  end

  it 'should run releaser' do
    result = releaser.run('ruby')

    expect(File.exist?(procfile_path)).to be_truthy
    expect(File.exist?(nginx_configs_path)).to be_truthy
    expect(File.exist?(supervisord_configs_path)).to be_truthy
    expect(result).to eq [nil, true]
  end
end
