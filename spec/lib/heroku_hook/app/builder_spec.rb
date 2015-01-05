require 'spec_helper'
include BuildHelper

RSpec.describe 'Builder' do
  prepare_build_environment
  it 'should build proper Ruby application' do
    builder = HerokuHook::App::Builder.new(build_receiver, build_config)

    expect { builder.run }
      .to output("\e[1GFetching repository, done.\n" \
                 "\e[1G-----> Ruby app detected\n" \
                 "\e[1G-----> Compiling Ruby/Rails\n" \
                 "\e[1G-----> Using Ruby version: ruby-2.1.5\n" \
                 "\e[1G-----> Installing dependencies using 1.6.3\n" \
                 "\e[1G       Running: bundle install --without development:test --path vendor/bundle " \
                              "--binstubs vendor/bundle/bin -j4 --deployment\n" \
                 "\e[1G       Installing hello-world 1.2.0\n"
    ).to_stdout
  end

  it 'should run command in context of the application' do
    builder = HerokuHook::App::Builder.new(build_receiver, build_config)
    FileUtils.mkdir_p(File.join(builder.app_path))

    expect { builder.run_command('pwd') }.to output(File.expand_path(builder.app_path) + "\n").to_stdout
  end

  it 'should run command for given context' do
    builder = HerokuHook::App::Builder.new(build_receiver, build_config)
    context_path = File.expand_path(File.join(builder.app_path, '..', '..', 'test-context', '_app'))
    FileUtils.mkdir_p(context_path)

    expect { builder.run_command('pwd', 'test-context') }.to output(context_path + "\n").to_stdout
  end
end
