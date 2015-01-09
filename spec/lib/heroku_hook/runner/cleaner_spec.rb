require 'spec_helper'
include BuildHelper

RSpec.describe 'Cleaner' do
  prepare_build_environment
  let(:cleaner) { HerokuHook::Runner::Cleaner.new }

  it 'should wipe out given directory' do
    path = File.join(build_projects_base_path, 'test')
    Dir.mkdir(path)
    File.open(File.join(path, '.a'), 'w') { |file| file.write('test') }
    File.open(File.join(path, 'b'), 'w') { |file| file.write('test') }
    Dir.mkdir(File.join(path, '.c'))
    Dir.mkdir(File.join(path, 'd'))

    cleaner.run(path)

    expect(Dir.glob(File.join(path, '*'))).to eq []
    expect(Dir.glob(File.join(path, '.*')).size).to eq 2
  end
end
