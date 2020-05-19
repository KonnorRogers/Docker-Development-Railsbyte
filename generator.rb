# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

RAILS_REQUIREMENT = ['>= 5.2.0', '< 7'].freeze
RUBY_REQUIREMENT = '>= 2.5.0'

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def minimum_rails_version?
  Gem::Requirement.new(RAILS_REQUIREMENT[0],
                       RAILS_REQUIREMENT[1]).satisfied_by? rails_version
end

def assert_minimum_rails_version
  return if minimum_rails_version?

  prompt = "This template requires Rails #{RAILS_REQUIREMENT[0]}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# The only way to be running rails is with the proper RUBY_VERSION, so no
# need to parse the lockfile.
def ruby_version
  @ruby_version ||= RUBY_VERSION
end

def minimum_ruby_version
  Gem::Requirement.new(RUBY_REQUIREMENT).satisfied_by? ruby_version
end

def assert_minimum_ruby_version
  return if minimum_ruby_version

  prompt = "This template requires Ruby #{ruby_version}. "\
           "You are using #{ruby_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_generator_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('docker-development-railsbyte-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/ParamagicDev/Docker-Development-Railsbyte.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{Docker-Development-Railsbyte/(.+)/generator.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

FILES = {
  DOCKERFILE: 'Dockerfile.dev',
  DOCKER_COMPOSE: 'docker-compose.yml',
  DOCKER_IGNORE: '.dockerignore',
  ENTRYPOINT_SCRIPT: 'entrypoint.sh',
  DATABASE_FILE: 'config/database.yml'
}.freeze

def ask_questions
  puts FILES.values
  if no?('The above files will be overwritten / created. Is this okay? (yes / no):')
    return
  end

  run "touch #{FILES.values.join(' ')}"
end

RUBY_VERSION = '2.6'
APP_DIR = '/home/user/myapp'
USER_ID =  Process.uid || 1000
GROUP_ID = Process.gid || 1000
USER = 'user'
NODE_VERSION = '12'

PORTS = { RAILS: '3000', WEBPACKER: '3035' }.freeze

POSTGRES_VERSION = '12.2'
DATABASE_USER = 'postgres'
DATABASE_PASSWORD = 'EXAMPLE'

def original_generation_of_files
  create_file FILES[:DOCKERFILE] do
  end

  create_file FILES[:DOCKER_COMPOSE] do
  end

  create_file FILES[:DOCKER_IGNORE] do
  end

  create_file FILES[:ENTRYPOINT_SCRIPT] do
    <<~EOF
    EOF
  end

  create_file FILES[:DATABASE_FILE] do
    <<~EOF
    EOF
  end
end

def copy_templates
  FILES.values.each { |file| copy_file(file) }
end

# Main
add_generator_repository_to_source_path

after_bundle do
  assert_minimum_rails_version
  original_generation_of_files
  say
  say 'Successfully added Docker to your project!'
  say 'To get started with Docker:', :blue
  say 'docker-compose up --build'
end
