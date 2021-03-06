require 'spec_helper'
include BuildHelper

RSpec.describe 'PortHandler' do
  let(:port_handler) { HerokuHook::PortHandler.new }

  before(:each) do
    HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    HerokuHook::Config.ports.path = build_projects_base_path
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
      @dummy_port_handler = HerokuHook::PortHandler.new
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
    let(:port_file) { File.join(HerokuHook::Config.ports.path, 'appx.port') }
    it 'automatic port' do
      dummy_port_handler = HerokuHook::PortHandler.new
      allow(dummy_port_handler).to receive(:pull) { 8000 }

      port = dummy_port_handler.store('appx')

      expect(port).to eq 8000
      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 8000
    end

    it 'not existing port' do
      port = port_handler.store('appx', 55_223)

      expect(port).to eq 55_223
      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 55_223
    end

    it 'existing port' do
      expect { port_handler.store('appx', 5200) }.to raise_error(ArgumentError)

      expect(File.exist?(port_file)).to be_falsey
    end
  end

  context '#fetch' do
    let(:port_file) { File.join(HerokuHook::Config.ports.path, 'appx.port') }
    it 'non-existing file' do
      dummy_port_handler = HerokuHook::PortHandler.new
      allow(dummy_port_handler).to receive(:pull) { 8000 }

      port = dummy_port_handler.fetch('appx')

      expect(port).to eq 8000
      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 8000
    end

    it 'existing file' do
      File.open(port_file, 'w') { |file| file.write('5432') }
      port = port_handler.fetch('appx')

      expect(port).to eq 5_432
      expect(File.exist?(port_file)).to be_truthy
      expect(File.read(port_file).to_i).to eq 5_432
    end
  end
end
