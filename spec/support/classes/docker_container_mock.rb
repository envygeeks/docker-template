class DockerContainerMock
  attr_reader :struct
  def initialize
    @mocked = [
      :delete,
      :streaming_logs,
      :attach,
      :stop
    ]
  end

  #

  def json
    {
      "State" => {
        "ExitCode" => 0
      }
    }
  end

  #

  def start(*args, &block)
    self
  end

  #

  def method_missing(method, *args, &block)
    if @mocked.include?(method)
      nil else super
    end
  end
end
