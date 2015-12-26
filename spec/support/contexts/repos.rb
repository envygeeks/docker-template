shared_context :repos do
  let :mocked_repos do
    Mocks::Repos.new \
      self
  end

  #

  after do
    mocked_repos.teardown
  end
end
