# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

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
  files.values.each { |file| copy_file(File.join(TEMPLATE_DIR, file)) }
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


# Main
add_generator_repository_to_source_path

# Need to require here, otherwise will cause an error
require_relative 'lib/questions.rb'
require_relative 'lib/utils.rb.rb'

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
