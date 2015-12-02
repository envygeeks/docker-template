RSpec.configure do |config|
  file = RSpec::Helpers.in_data { Docker::Template.repos_root.join("sym3/file") }
  config. after(:suite) { FileUtils.rm file }
  config.before(:suite) do
    FileUtils.rm_f file
    File.symlink "/tmp", file
  end
end
