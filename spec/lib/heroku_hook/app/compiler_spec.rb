require 'spec_helper'
include BuildHelper

RSpec.describe 'Compiler' do
  prepare_build_environment

  it 'should build proper Ruby application' do
    compiler = HerokuHook::App::Compiler.new(build_receiver, build_config)
    result = nil

    expect { result = compiler.run('ruby') }.to output(
      "\e[1G-----> Compiling Ruby/Rails\n" \
      "\e[1G-----> Using Ruby version: ruby-2.1.5\n" \
      "\e[1G-----> Installing dependencies using 1.6.3\n" \
      "\e[1G       Running: bundle install --without development:test --path vendor/bundle " \
                   "--binstubs vendor/bundle/bin -j4 --deployment\n" \
      "\e[1G       Installing hello-world 1.2.0\n"
    ).to_stdout

    expect(result).to eq [nil, true]
  end
end
