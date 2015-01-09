module HerokuHook
  module Runner
    # Runs buildback hook and builds an application
    class Compiler < HerokuHook::Runner::Base
      def run(language)
        run_with_envs({ 'STACK' => Config.stack }, command('compile', language), rawout: false)
        [nil, @success]
      end
    end
  end
end
