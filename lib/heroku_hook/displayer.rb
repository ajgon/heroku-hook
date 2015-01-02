module HerokuHook
  # Sends given strings to standard output
  class Displayer
    def self.out(str = '', stream = $stdout)
      stream.write "\e[1G" + str
      stream.flush
    end

    def self.outln(str = '', stream = $stdout)
      stream.puts "\e[1G" + str
      stream.flush
    end

    def self.raw_out(str = '', stream = $stdout)
      stream.write str
      stream.flush
    end

    def self.raw_outln(str = '', stream = $stdout)
      stream.puts str
      stream.flush
    end

    # rubocop:disable Lint/AssignmentInCondition
    def self.pass_stream(from_stream, to_stream, opts = { rawout: true })
      Thread.new do
        while line = from_stream.gets
          HerokuHook::Displayer.send((opts[:rawout] ? 'raw_out' : 'out'), line, to_stream)
        end
      end
    end
    # rubocop:enable Lint/AssignmentInCondition
  end
end
