RSpec.configure do |config|
  file = RSpec::Helpers.in_data do
    Docker::Template.repos_root.join("sym3/file")
  end

  #

  config.after :suite do
    FileUtils.rm file
  end

  #

  config.before :suite do
    FileUtils.rm_f file
    File.symlink "/tmp", file
  end
end
