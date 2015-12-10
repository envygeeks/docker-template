shared_context :docker_mocks do
  before do
    allow(Docker::Container).to receive(:create) do
      docker_container_mock
    end
  end

  #

  let :docker_container_mock do
    DockerContainerMock.new
  end

  #

  before do
    allow(Docker::Image).to receive(:build_from_dir) do
      docker_image_mock
    end
  end

  #

  let :docker_image_mock do
    DockerImageMock.new
  end
end
