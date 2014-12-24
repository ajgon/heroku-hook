module HerokuHook
  # Class used to handle environment variables
  class EnvHandler
    attr_reader :envs

    def initialize(context = {})
      @envs = {}
      @context = context
    end

    def load_file(path)
      result = ''
      Open3.popen3(@context, command(path)) { |_stdin, stdout| result = stdout.read }
      add_to_envs(Hash[result.split("\n").map { |line| line.split('=', 2) }])
    end

    def to_s(separator = "\n")
      @envs.to_a.map { |env| env.join('=') }.join(separator)
    end

    private

    def add_to_envs(envs)
      @envs.merge!(envs)
      envs
    end

    def command(path)
      "EOF=EOF_\$RANDOM; eval echo \"\\\"\$(cat <<\$EOF\n\$(<#{path})\n\$EOF\n)\\\"\" | sed \"s@^export\s*@@g\""
    end
  end
end
