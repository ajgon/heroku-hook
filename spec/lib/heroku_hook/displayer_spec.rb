require 'spec_helper'

RSpec.describe 'Display' do
  it 'should display output correctly' do
    expect { HerokuHook::Displayer.out('test') }.to output("\e[1Gtest").to_stdout
    expect { HerokuHook::Displayer.outln('test') }.to output("\e[1Gtest\n").to_stdout
    expect do
      HerokuHook::Displayer.out('test')
      HerokuHook::Displayer.raw_out(' is')
      HerokuHook::Displayer.raw_outln(' ok')
    end.to output("\e[1Gtest is ok\n").to_stdout
  end
end
