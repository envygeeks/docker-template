# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

shared_context :repos do
  before do
    mocked_repo.setup
  end

  #

  let :mocked_repo do
    Mocks::Repo.new(
      self
    )
  end

  #

  after do
    mocked_repo.teardown
  end
end
