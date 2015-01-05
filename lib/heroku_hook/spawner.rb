require 'English'
require 'sys/proctable'

module HerokuHook
  # Used for spawning killable, blocking shell command with environment variables attached
  class Spawner
    # Ugly hack to make supervisor killing subprocesses
    def self.spawn(envs, cmd, opts = {})
      opts = { rawout: true, context: Dir.pwd }.merge(opts)
      IO.popen(popen_cmd(envs, cmd, opts[:context]), 'w+') do |pipe|
        catch_kill unless defined?(RSPEC) && RSPEC
        handle_pipe(pipe, opts)
      end
      $CHILD_STATUS.success?
    end

    #:nocov:
    def self.catch_kill
      heroku_hook_pid = child_pid(Process.pid)
      command_pid = child_pid(heroku_hook_pid)
      %w(VTALRM QUIT EXIT).each do |signal|
        set_trap(signal, heroku_hook_pid, command_pid)
      end
    end

    def self.set_trap(signal, heroku_hook_pid, command_pid)
      trap(signal) do
        Process.kill('KILL', heroku_hook_pid)
        Process.kill('TERM', command_pid)
      end
    end

    def self.handle_pipe(pipe, opts = {})
      pipe.each { |line| HerokuHook::Displayer.send((opts[:rawout] ? :raw_out : :out), line) }
    end

    def self.popen_cmd(envs, cmd, context = Dir.pwd)
      spawn_cmd = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'spawn.sh'))
      [envs, spawn_cmd, context, cmd, err: $stderr]
    end

    def self.child_pid(pid)
      Sys::ProcTable.ps.select { |pe| pe.ppid == pid }.map(&:pid).first
    end
    #:nocov:
  end
end
