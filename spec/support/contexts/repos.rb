# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

shared_context :repos do
  before do |ex|
    mocked_repo.setup
    ex.metadata[:layout] ||= :complex
    ex.metadata[:type]   ||= :scratch

    unless ex.metadata[:init] == false
      mocked_repo.init({
        :type   => ex.metadata[:type],
        :layout => ex.metadata[:layout]
      })
    end
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
