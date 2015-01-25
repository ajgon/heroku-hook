module HerokuHook
  module Runner
    # Restarts deployed application
    class Launcher < HerokuHook::Runner::Base
      def restart
        HerokuHook::Displayer.out '-----> Launching... '
        system 'echo "\n\n\n" | sudo -S supervisorctl reread > /dev/null'
        system "echo \"\\n\\n\\n\" | sudo -S supervisorctl restart #{HerokuHook::Config.project_name}:* > /dev/null"
        HerokuHook::Displayer.raw_outln 'done'
      end

      def run
        restart
        HerokuHook::Displayer.outln "       http://#{HerokuHook::Config.project_name}." \
        "#{Config.project.base_domain}/ deployed"
        HerokuHook::Displayer.outln ''
      end
    end
  end
end
