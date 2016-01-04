# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

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
