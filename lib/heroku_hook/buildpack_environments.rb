module HerokuHook
  # Simple module for returning extra environmental variables for different buildpacks
  module BuildpackEnvironments
    module_function

    def ruby
      { 'HOME' => app_path }
    end

    def php
      {
        'HOME' => app_path,
        'LD_LIBRARY_PATH' => "#{app_path}/.heroku/php/lib",
        'PHP_INI_SCAN_DIR' => "#{app_path}/.heroku/php/etc/php/conf.d"
      }
    end

    def self.app_path
      File.join(Config.project.base_path, Config.project_name, Config.dirs.app)
    end
  end
end
