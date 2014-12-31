require 'spec_helper'

def build_detector_for(path)
  config.project.base_path = File.join(RSpec.configuration.fixture_path, 'apps', path)
  HerokuHook::App::Detector.new(receiver, config)
end

def expect_app_not_detected(path)
  detector = build_detector_for(path)
  success = false
  expect { success = detector.run.last }
    .to output("\e[1G !     Push rejected, no Cedar-supported app detected\n").to_stdout
  expect(success).to be_falsey
end

def expect_app_detected(path, type_name)
  detector = build_detector_for(path)
  success = false

  expect { success = detector.run }.to output("\e[1G-----> #{type_name} app detected\n").to_stdout
  expect(success).to be_truthy
end

def check_if_app_detects_properly(path, type_name = nil)
  if type_name
    expect_app_detected(path, type_name)
  else
    expect_app_not_detected(path)
  end
end

RSpec.describe 'Detector' do
  let(:buildpacks_path) do
    File.join(RSpec.configuration.fixture_path, 'buildpacks')
  end

  let(:receiver) do
    HerokuHook::Receiver.new(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git'))
  end

  let(:config) do
    conf = HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    conf.buildpacks.path = buildpacks_path
    conf
  end

  it 'should detect Ruby application' do
    check_if_app_detects_properly('ruby', 'Ruby')
  end

  it 'should detect Node.js application' do
    check_if_app_detects_properly('nodejs', 'Node.js')
  end

  it 'should detect Clojure application' do
    check_if_app_detects_properly('clojure', 'Clojure')
  end

  it 'should detect Python application' do
    check_if_app_detects_properly('python', 'Python')
  end

  it 'should detect Java application' do
    check_if_app_detects_properly('java', 'Java')
  end

  it 'should detect Gradle application' do
    check_if_app_detects_properly('gradle', 'Gradle')
  end

  it 'should detect Grails application' do
    check_if_app_detects_properly('grails', 'Grails')
  end

  it 'should detect Scala application' do
    check_if_app_detects_properly('scala', 'Scala')
  end

  it 'should detect Play application' do
    check_if_app_detects_properly('play', 'Play!')
  end

  it 'should detect PHP application' do
    check_if_app_detects_properly('php', 'PHP')
  end

  it 'should detect Java application when many concuring detectable files are present' do
    check_if_app_detects_properly('multiple', 'Java')
  end

  it 'should not detect any application' do
    check_if_app_detects_properly('no-known-project')
  end
end
