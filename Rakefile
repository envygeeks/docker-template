# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "docker/template/ansi"
require "rspec/core/rake_task"
require "open3"

task :default => [:spec]
RSpec::Core::RakeTask.new :spec
task :test => :spec

task :build do
  exec "bundle", "exec", "bin/docker-template", *ARGV[
    1..-1
  ]
end

task :pry do
  sh "bundle", "exec", "pry", "-Ilib/", \
    "-rdocker/template"
end

task :analysis do
  ansi = Docker::Template::Ansi
  cmd = [
    "docker", "run", "--rm", "--env=CODE_PATH=#{Dir.pwd}", \
    "--volume=#{Dir.pwd}:/code", "--volume=/var/run/docker.sock:/var/run/docker.sock", \
    "--volume=/tmp/cc:/tmp/cc", "-i", "codeclimate/codeclimate", "analyze"
  ]

  file = File.open(".analysis", "w+")
  Open3.popen3(cmd.shelljoin) do |_, out, err, _|
    while (data = out.gets)
      file.write data
      if data =~ /\A==/
        $stdout.print ansi.yellow(data)

      elsif data !~ %r!\A[0-9\-]+!
        $stdout.puts data

      else
        h, d = data.split(":", 2)
        $stdout.print ansi.cyan(h)
        $stdout.print ":", d
      end
    end

    while (data = err.gets)
      file.write data
      $stderr.print ansi.red(data)
    end
  end

  file.close
end
