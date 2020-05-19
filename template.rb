# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('Docker-Development-Railsbyte-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/ParamagicDev/Docker-Development-Railsbyte.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{Docker-Development-Railsbyte/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

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

def ask_questions
  @ruby_version = ruby_version_ask(@ruby_version)
  @node_version = node_version_ask(@node_version)
  @app_dir = app_dir_ask(@app_dir)
  @user_id = user_id_ask(@user_id)
  @group_id = group_id_ask(@group_id)
  @username = username_ask(@username)
  @rails_port = rails_port_ask(@rails_port)
  @webpacker_port = webpacker_port_ask(@webpacker_port)
  @postgres_version = postgres_version_ask(@postgres_version)
  @postgres_user = postgres_username_ask(@postgres_user)
  @postgres_password = postgres_password_ask(@postgres_password)
end

def ruby_version_ask(ruby_version)
  question = 'What version of Ruby would you like in your Dockerfile?'
  format = '[2.7, 2.7.1, 2.7.2 etc]'
  note = "\n Be aware, if this does not match the Ruby Version in your Gemfile
         you will encounter errors"

  ask("#{question} #{format} #{note}", default: ruby_version)
end

def node_version_ask(node_version)
  question = 'What version of Node would you like to use in your Dockerfile?'
  format = '[12, 11, 10, etc]'
  ask("#{question} #{format}", default: node_version)
end

def app_dir_ask(app_dir)
  question = 'Where would you like your app saved in your Dockerfile?'
  format = '[/home/user/myapp]'
  ask("#{question} #{format}", default: app_dir)
end

def id_ask(id, type)
  question = "What #{type}_id would you like to use?"
  format = '[1000, 2000, 3000, etc]'
  ask("#{question} #{format}", default: id)
end

def user_id_ask(user_id)
  id_ask(user_id, 'user')
end

def username_ask(username)
  ask('What username would you like to use?', default: username)
end

def group_id_ask(group_id)
  id_ask(group_id, 'group')
end

def port_ask(port, service)
  question = "What port would you like to use for #{service}?"
  format = '[3000, 3035, 8000, 8080, etc]'

  ask("#{question} #{format}", default: port)
end

def rails_port_ask(rails_port)
  port_ask(rails_port, 'Rails')
end

def webpacker_port_ask(webpacker_port)
  port_ask(webpacker_port, 'Webpacker')
end

def postgres_version_ask(version)
  question = 'What version of postgres would you like to use?'
  format = '[12, 11, 10, etc]'
  note = "\n Please make sure this version exists here: https://hub.docker.com/_/postgres"
  ask("#{question} #{format} #{note}", default: version)
end

def postgres_password_ask(password)
  question = 'What password would you like to use for postgres?'
  format = '[password1, password2, etc]'
  ask("#{question} #{format}", default: password)
end

def postgres_name_ask(username)
  question = 'What would you like to use as your Postgres username?'
  format = '[supercoolguy, databaseadmin, etc]'
  note = "\n Be aware, there are issues with changing the Postgres username\n
          https://hub.docker.com/_/postgres for full details"

  ask("#{question} #{format} #{note}", default: username)
end

TEMPLATE_DIR = 'templates'
def copy_templates(files)
  puts files.values
  if no?('The above files will be overwritten / created. Is this okay? (yes / no):')
    return
  end

  run "touch #{files.values.join(' ')}"
  files.values.each { |file| copy_file(File.join(TEMPLATE_DIR, file)) }
end

def set_file_defaults
  @files = {
    dockerfile: 'Dockerfile.dev',
    docker_compose: 'docker-compose.yml',
    docker_ignore: '.dockerignore',
    entrypoint_script: 'entrypoint.sh',
    database_files: 'config/database.yml'
  }
end

def set_version_defaults
  @ruby_version = RUBY_VERSION || '2.6.3'
  @node_version = ENV['NODE_VERSION'] || '12'
end

# Do not set up POSTGRES_USER from ENV Variables due to issues with
# Postgres usernames, username must be set via prompt
# Do not set POSTGRES_PASSWORD from ENV variables so you dont expose a users
# true password in plain text
def set_postgres_defaults
  @postgres_version = ENV['POSTGRES_VERSION'] || '12'
  @postgres_user = 'postgres'
  @postgres_password = 'EXAMPLE'
end

def set_defaults
  set_file_defaults
  set_version_defaults
  set_postgres_defaults

  @app_dir = ENV['APP_DIR'] || '/home/user/myapp'
  @user_id =  Process.uid || 1000
  @group_id = Process.gid || 1000
  @username = ENV['DOCKER_USERNAME'] || 'user'

  @ports = { rails: ENV['RAILS_PORT'] || '3000',
             webpacker: ENV['WEBPACKER_PORT'] || '3035' }
end

# Main
add_generator_repository_to_source_path

after_bundle do
  assert_minimum_ruby_version
  assert_minimum_rails_version
  set_defaults

  ask_questions if no?('Would you like to use the defaults? (yes / no)')

  copy_templates(@files)

  say
  say 'Successfully added Docker to your project!'
  say 'To get started with Docker:', :blue
  say 'docker-compose up --build'
end
