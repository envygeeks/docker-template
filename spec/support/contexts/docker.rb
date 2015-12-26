shared_context :docker do
  before do
    allow(Docker::Container).to receive(:create) do
      container_mock
    end
  end

  #

  let :container_mock do
    Mocks::Container \
      .new
  end

  #

  before do
    allow(Docker::Image).to receive(:build_from_dir) do
      image_mock
    end
  end

  #

  let :image_mock do
    Mocks::Image \
      .new
  end
end
