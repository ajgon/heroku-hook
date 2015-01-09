require 'spec_helper'

# :reek:UtilityFunction
def build_detector_for(path)
  HerokuHook::Config.project.base_path = File.join(RSpec.configuration.fixture_path, 'apps', path)
  HerokuHook::Config.project_name = 'bare'
  HerokuHook::Runner::Detector.new
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
  before(:all) do
    HerokuHook::Receiver.handle(File.join(RSpec.configuration.fixture_path, 'repos', 'bare.git'))
    HerokuHook::Config.load(File.join(RSpec.configuration.fixture_path, 'config', 'heroku-hook.yml'))
    HerokuHook::Config.buildpacks.path = File.join(RSpec.configuration.fixture_path, 'buildpacks')
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
