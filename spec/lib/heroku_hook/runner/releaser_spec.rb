require 'spec_helper'
include BuildHelper

RSpec.describe 'Releaser' do
  before(:all) do
    prepare_build_environment
  end

  context 'Prepared environment' do
    let(:releaser) { HerokuHook::Runner::Releaser.new }
    let(:fetcher) { HerokuHook::Runner::Fetcher.new }
    let(:port) { HerokuHook::PortHandler.new.fetch HerokuHook::Config.project_name }
    let(:procfile_path) { File.join(HerokuHook::Config.project.base_path, 'bare', '_app', 'Procfile') }
    let(:env_path) { File.join(HerokuHook::Config.project.base_path, 'bare', '_app', '.profile.d', 'ruby.sh') }
    let(:nginx_configs_path) { File.join(HerokuHook::Config.nginx.configs_path, 'bare.conf') }
    let(:supervisord_configs_path) { File.join(HerokuHook::Config.supervisord.configs_path, 'bare.conf') }

    before(:each) do
      fetcher.run
      FileUtils.mkdir_p(File.dirname(env_path))
      File.open(env_path, 'w') do |file|
        file.write File.read(File.join(RSpec.configuration.fixture_path, '.profile.d', 'ruby.sh'))
      end
      releaser.build_release_config('ruby')
      releaser.prepare_release_variables('ruby')
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

    it 'should create a file with release environmental variables' do
      env_file_contents = File.read(File.join(releaser.env_path, '_default.env'))
      app_path = releaser.app_path

      expect(env_file_contents).to eq(
        "GEM_PATH=#{app_path}/vendor/bundle/ruby/2.1.0:#{ENV['GEM_PATH']}\n" \
        "LANG=#{ENV['LANG']}\n" \
        "PATH=#{app_path}/bin:#{app_path}/vendor/bundle/bin:#{app_path}/vendor/bundle/ruby/2.1.0/bin:#{ENV['PATH']}\n" \
        "RACK_ENV=#{rack_env}\n" \
        "RAILS_ENV=#{rails_env}\n" \
        "SECRET_KEY_BASE=loremipsum\n" \
        "QUOTES_VAR=quotes here\n" \
        'SINGLE_QUOTES_VAR=single quotes here' \
        "\nHOME=#{app_path}"
      )
    end

    context 'procfile' do
      it 'should be built if none present' do
        releaser.build_procfile

        expect(File.exist?(procfile_path)).to be_truthy
        expect(File.read(procfile_path))
          .to eq "web: bin/rails server -p #{port} -e #{rails_env}\n"
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
      releaser.build_nginx_config

      nginx_config = File.read(nginx_configs_path)
      base_log_path = HerokuHook::Config.project.base_log_path

      expect(File.exist?(nginx_configs_path)).to be_truthy

      expect(nginx_config).to match(/^upstream bare \{$/)
      expect(nginx_config).to match(/server localhost:#{port}/)
      expect(nginx_config).to match(%r{access_log #{base_log_path}/bare/bare-nginx-access.log})
      expect(nginx_config).to match(%r{error_log  #{base_log_path}/bare/bare-nginx-error.log})
      expect(nginx_config).to match(/server_name\s+bare.lvh.me;/)
      expect(nginx_config).to match(%r{root .*/spec/fs-sandbox/bare/_app/public;})
      expect(nginx_config).to match(%r{proxy_pass http://bare;})
    end

    it 'should generate proper supervisord config' do
      releaser.build_procfile
      releaser.build_supervisord_config

      supervisord_config = File.read(supervisord_configs_path)
      base_log_path = HerokuHook::Config.project.base_log_path

      expect(File.exist?(supervisord_configs_path)).to be_truthy
      expect(supervisord_config).to match(/^\[program:bare-web-1\]$/)
      expect(supervisord_config).to match(/^command=heroku-hook run-for-bare bin\/rails server/)
      expect(supervisord_config).to match(%r{^stdout_logfile=#{base_log_path}/bare/web-1.log$})
      expect(supervisord_config).to match(%r{^stderr_logfile=#{base_log_path}/bare/web-1.error.log$})
      expect(supervisord_config).to match(/^user=git$/)
      expect(supervisord_config).to match(%r{^directory=.*/spec/fs-sandbox/bare/_app$})
      expect(supervisord_config).to match(/^environment=.*HOME="#{releaser.app_path}"/)
      expect(supervisord_config).to match(/^environment=.*PORT="#{port}"/)
      expect(supervisord_config).to match(/^environment=.*RACK_ENV="#{rack_env}"/)
      expect(supervisord_config).to match(/^environment=.*RAILS_ENV="#{rails_env}"/)
    end

    it 'should run releaser' do
      result = releaser.run('ruby')

      expect(File.exist?(procfile_path)).to be_truthy
      expect(File.exist?(nginx_configs_path)).to be_truthy
      expect(File.exist?(supervisord_configs_path)).to be_truthy
      expect(result).to eq [nil, true]
    end
  end
end
