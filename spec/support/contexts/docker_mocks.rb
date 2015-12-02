shared_context :docker_mocks do
  let(:docker_image_mock) { DockerImageMock.new }
  let(:docker_container_mock) { DockerContainerMock.new }
  before do
    allow(Docker::Container).to receive(:create).and_return docker_container_mock
    allow(Docker::Image).to receive(:build_from_dir).and_return docker_image_mock
  end
end
