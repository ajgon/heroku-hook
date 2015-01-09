lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'heroku-hook'
  gem.version       = '0.0.10'
  gem.authors       = ['Igor Rzegocki']
  gem.email         = ['ajgon@irgon.com']
  gem.description   = 'Heroku-like post-receive hook, which sets up the application and detects buildpacks'
  gem.summary       = 'Heroku-like post-receive hook'
  gem.homepage      = 'https://github.com/ajgon/heroku-hook'

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.require_paths = ['lib']

  gem.add_dependency('git')
  gem.add_dependency('dotenv')
  gem.add_dependency('sys-proctable')
  gem.add_dependency('foreman')
  gem.add_dependency('foreman-export-nginx')
end
