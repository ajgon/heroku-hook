require 'spec_helper'
include BuildHelper

RSpec.describe 'EnvHandler' do
  context 'variables loaded from file' do
    let(:context) do
      {
        'HOME' => '/tmp',
        'GEM_PATH' => '/tmp/gems',
        'LANG' => 'C',
        'PATH' => '/tmp/home:/usr/bin:/bin',
        'RACK_ENV' => 'development',
        'RAILS_ENV' => 'test',
        'SECRET_KEY_BASE' => 'something'
      }
    end
    let(:env_file) { File.join(RSpec.configuration.fixture_path, '.profile.d', 'ruby.sh') }

    it 'should load without context' do
      env_handler = HerokuHook::EnvHandler.new
      env_handler.load_files([env_file])

      expect(env_handler.envs['GEM_PATH']).to match %r{vendor/bundle/ruby/2.1.0:}
      expect(env_handler.envs['PATH']).to match %r{/vendor/bundle/bin:}
      expect(env_handler.envs['PATH']).to match %r{/vendor/bundle/ruby/2.1.0/bin:}
      expect(env_handler.envs['RACK_ENV']).to eq rack_env
      expect(env_handler.envs['RAILS_ENV']).to eq rails_env
      expect(env_handler.envs['SECRET_KEY_BASE']).to eq 'loremipsum'
      expect(env_handler.envs['QUOTES_VAR']).to eq 'quotes here'
      expect(env_handler.envs['SINGLE_QUOTES_VAR']).to eq 'single quotes here'
    end

    it 'should load with ENV context' do
      env_handler = HerokuHook::EnvHandler.new(context)
      env_handler.load_file(env_file)

      expect(env_handler.envs).to eq(
        'GEM_PATH' => '/tmp/vendor/bundle/ruby/2.1.0:/tmp/gems',
        'LANG' => 'C',
        'PATH' => '/tmp/bin:/tmp/vendor/bundle/bin:/tmp/vendor/bundle/ruby/2.1.0/bin:/tmp/home:/usr/bin:/bin',
        'RACK_ENV' => 'development',
        'RAILS_ENV' => 'test',
        'SECRET_KEY_BASE' => 'something',
        'QUOTES_VAR' => 'quotes here',
        'SINGLE_QUOTES_VAR' => 'single quotes here'
      )
    end

    it 'should return output in ENV=val format' do
      env_handler = HerokuHook::EnvHandler.new(context)
      env_handler.load_file(env_file)

      expect(env_handler.to_s).to eq(
        "GEM_PATH=/tmp/vendor/bundle/ruby/2.1.0:/tmp/gems\n" \
        "LANG=C\n" \
        "PATH=/tmp/bin:/tmp/vendor/bundle/bin:/tmp/vendor/bundle/ruby/2.1.0/bin:/tmp/home:/usr/bin:/bin\n" \
        "RACK_ENV=development\n" \
        "RAILS_ENV=test\n" \
        "SECRET_KEY_BASE=something\n" \
        "QUOTES_VAR=quotes here\n" \
        'SINGLE_QUOTES_VAR=single quotes here'
      )
    end
  end
end
