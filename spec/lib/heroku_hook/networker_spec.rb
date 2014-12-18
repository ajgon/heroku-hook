require 'spec_helper'

RSpec.describe 'Networker' do
  it 'should get first free port' do
    free_port = HerokuHook::Networker.free_port
    restricted_free_port = HerokuHook::Networker.restricted_free_port

    expect(free_port).to be > 0
    expect(free_port).to be < 65_536
    expect(restricted_free_port).to be > 1024
    expect(restricted_free_port).to be < 64_001
  end
end
