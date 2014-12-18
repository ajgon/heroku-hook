require 'spec_helper'
include BuildHelper

def create_port_store(name, port)
  File.open(File.join(config.ports_directory, "#{name}.port"), 'w') { |file| file.write(port.to_s) }
end

RSpec.describe 'PortHandler' do
  let(:config) do
    config = HerokuHook::Config.new(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    config.ports_directory = build_projects_base_path
    config
  end
  let(:port_handler) { HerokuHook::PortHandler.new(config) }

  before(:each) do
    create_port_store('app1', 1546)
    create_port_store('app2', 3000)
    create_port_store('app3', 5000)
    create_port_store('app4', 63_254)
  end

  it '#raw_free_port' do
    expect(port_handler.raw_free_port).to be > 0
    expect(port_handler.raw_free_port).to be < 65_536
  end

  it '#raw_taken_ports' do
    expect(port_handler.raw_taken_ports).to eq [1546, 3000, 5000, 63_254]
  end

  it '#taken_ports' do
    expect(port_handler.taken_ports)
      .to eq [1546, 1646, 1746, 1846, 1946, 2046, 3000, 3100, 3200, 3300, 3400, 3500, 5000, 5100, 5200, 5300, 5400,
              5500, 63_254, 63_354, 63_454, 63_554, 63_654, 63_754]
  end

  context '#pull' do
    before(:each) do
      @dummy_port_handler = HerokuHook::PortHandler.new(config)
    end

    it 'starts with too small' do
      dummy_port = 1000
      allow(@dummy_port_handler).to receive(:raw_free_port) { dummy_port += 1 }

      expect(@dummy_port_handler.pull).to eq 1025
    end

    it 'starts with too big' do
      dummy_port = 64_250
      allow(@dummy_port_handler).to receive(:raw_free_port) { dummy_port -= 1 }

      expect(@dummy_port_handler.pull).to eq 64_000
    end

    it 'starts with restricted' do
      dummy_port = 3000
      allow(@dummy_port_handler).to receive(:raw_free_port) { dummy_port += 100 }

      expect(@dummy_port_handler.pull).to eq 3600
    end
  end

  context '#store' do
    let(:port_file) { File.join(config.ports_directory, 'appx.port') }
    it 'automatic port' do
      dummy_port_handler = HerokuHook::PortHandler.new(config)
      allow(dummy_port_handler).to receive(:pull) { 8000 }

      dummy_port_handler.store('appx')

      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 8000
    end

    it 'not existing port' do
      port_handler.store('appx', 55_223)

      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 55_223
    end

    it 'existing port' do
      expect { port_handler.store('appx', 5200) }.to raise_error(ArgumentError)

      expect(File.exist?(port_file)).to be_falsey
    end
  end
end
