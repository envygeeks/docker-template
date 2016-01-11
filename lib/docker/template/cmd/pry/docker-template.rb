Pry::Commands.block_command "docker-template", "Build your repos" do |*repos|
  begin
    repos = Pry.config.docker_template_repos unless repos.size > 0
    argv  = Pry.config.docker_template_argv
    Docker::Template::Parser.new(repos, argv) \
      .parse.map(&:build)
      
  rescue Docker::Template::Error::StandardError => e
    STDERR.puts Simple::Ansi.red(e.message)
  end
end
