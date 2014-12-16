require 'spec_helper'

RSpec.describe 'Display' do
  it 'should display output correctly' do
    expect { HerokuHook::Display.out('test') }.to output("\e[1Gtest").to_stdout
    expect { HerokuHook::Display.outln('test') }.to output("\e[1Gtest\n").to_stdout
    expect do
      HerokuHook::Display.out('test')
      HerokuHook::Display.raw_out(' is')
      HerokuHook::Display.raw_outln(' ok')
    end.to output("\e[1Gtest is ok\n").to_stdout
  end
end
