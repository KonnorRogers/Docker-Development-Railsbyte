# frozen_string_literal: true

require 'fileutils'
require 'shellwords'
require 'erb'
# Need to require here, otherwise will cause an error

RAILS_REQUIREMENT = ['>= 5.2.0', '< 7'].freeze
RUBY_REQUIREMENT = '>= 2.5.0'
TEMPLATE_DIR = 'templates'

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

def copy_templates(files)
  puts files.values
  if no?('The above files will be overwritten / created. Is this okay? (yes / no):')
    return
  end

  run "touch #{files.values.join(' ')}"
  files.values.each do |file|
    filename = File.join(TEMPLATE_DIR, 'erb', file)
    copy_file(File.read(filename))
  end
end

def ask_rails_runtime_questions
  @ruby_version = ruby_version_ask(@ruby_version)
  @node_version = node_version_ask(@node_version)
  @rails_port = rails_port_ask(@rails_port)
  @webpacker_port = webpacker_port_ask(@webpacker_port)
end

def ask_postgres_questions
  @postgres_version = postgres_version_ask(@postgres_version)
  @postgres_user = postgres_username_ask(@postgres_user)
  @postgres_password = postgres_password_ask(@postgres_password)
end

def ask_docker_questions
  @username = username_ask(@username)
  @app_dir = app_dir_ask(@app_dir)
  @user_id = user_id_ask(@user_id)
  @group_id = group_id_ask(@group_id)
end

def ask_questions
  ask_rails_runtime_questions
  ask_postgres_question
  ask_docker_questions
end

# Main
add_template_repository_to_source_path

require_relative 'lib/questions'
require_relative 'lib/utils'
after_bundle do
  assert_minimum_ruby_version(RUBY_REQUIREMENT)
  assert_minimum_rails_version(RAILS_REQUIREMENT[0], RAILS_REQUIREMENT[1])

  set_defaults

  ask_questions if no?('Would you like to use the defaults? (yes / no)')

  copy_templates(@files)

  say
  say 'Successfully added Docker to your project!'
  say 'To get started with Docker:', :blue
  say 'docker-compose up --build'
end
