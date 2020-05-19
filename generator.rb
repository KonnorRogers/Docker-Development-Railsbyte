# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

RAILS_REQUIREMENT = ['>= 5.2.0', '< 7'].freeze

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def minimum_rails_version?
  Gem::Requirement.new(RAILS_REQUIREMENT[0], RAILS_REQUIREMENT[1]).satisfied_by? rails_version
end

def assert_minimum_rails_version
  return if minimum_rails_version?

  prompt = "This template requires Rails #{RAILS_REQUIREMENT[0]}. "\
           "You are using #{rails_version}. Continue anyway?"
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

PORTS = { RAILS: '3000', WEBPACKER: '3035' }.freeze

POSTGRES_VERSION = '12.2'
DATABASE_USER = 'postgres'
DATABASE_PASSWORD = 'EXAMPLE'

def original_generation_of_files
  create_file FILES[:DOCKERFILE] do
    <<~EOF
      # Pre setup stuff
      FROM ruby:#{RUBY_VERSION} as builder

      # Add Yarn to the repository
      RUN curl https://deb.nodesource.com/setup_12.x | bash && \\
          curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \\
          echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

      # Install system dependencies & clean them up
      # libnotify-dev is what allows you to watch file changes w/ HMR
      RUN apt-get update -qq && apt-get install -y \\
          postgresql-client build-essential yarn nodejs \\
          libnotify-dev && \\
          rm -rf /var/lib/apt/lists/*

      # This is where we build the rails app
      FROM builder as rails-app

      # Allow access to port 3000 & 3035
      EXPOSE #{PORTS[:RAILS]}
      EXPOSE #{PORTS[:WEBPACKER]}

      # This is to fix an issue on Linux with permissions issues
      ARG USER_ID=#{USER_ID}
      ARG GROUP_ID=#{GROUP_ID}
      ARG APP_DIR=#{APP_DIR}

      # Create a non-root user
      RUN groupadd --gid $GROUP_ID #{USER}
      RUN useradd --no-log-init --uid $USER_ID --gid $GROUP_ID #{USER} --create-home

      # Remove existing running server
      COPY entrypoint.sh /usr/bin/
      RUN chmod +x /usr/bin/#{FILES[:ENTRYPOINT_SCRIPT]}

      # fixing Permissions
      RUN mkdir -p $APP_DIR
      RUN chown -R $USER_ID:$GROUP_ID $APP_DIR

      # Define the user running the container
      USER $USER_ID:$GROUP_ID

      WORKDIR $APP_DIR

      # Install rails related dependencies
      COPY --chown=$USER_ID:$GROUP_ID Gemfile* $APP_DIR/

      # For webpacker / node_modules
      COPY --chown=$USER_ID:$GROUP_ID package.json $APP_DIR
      COPY --chown=$USER_ID:$GROUP_ID yarn.lock $APP_DIR

      # Fix an issue with outdated bundler
      RUN gem install bundler
      RUN bundle install

      # Copy over all files
      COPY --chown=$USER_ID:$GROUP_ID . .

      RUN yarn install --check-files


      ENTRYPOINT ["/usr/bin/#{FILES[:ENTRYPOINT_SCRIPT]}"]

      # Start the main process.
      CMD ["rails", "server", "-p", "#{PORTS[:RAILS]}", "-b", "0.0.0.0"]

    EOF
  end

  create_file FILES[:DOCKER_COMPOSE] do
    <<~EOF
      version: '3'

      services:
        web:
          environment:
            NODE_ENV: development
            RAILS_ENV: development
            WEBPACKER_DEV_SERVER_HOST: 0.0.0.0
            POSTGRES_USER: #{DATABASE_USER}
            POSTGRES_PASSWORD: #{DATABASE_PASSWORD}

          build:
            context: .
            dockerfile: #{FILES[:DOCKERFILE]}
            args:
              USER_ID: #{USER_ID}
              GROUP_ID: #{GROUP_ID}
              APP_DIR: #{APP_DIR}

          command: bash -c "rm -f tmp/pids/server.pid &&
                            ./bin/webpack-dev-server --port #{PORTS[:WEBPACKER]} &
                            bundle exec rails server -p #{PORTS[:RAILS]} -b '0.0.0.0'"

          volumes:
            # make sure this lines up with APP_DIR above
            - .:#{APP_DIR}
            - node_modules:#{APP_DIR}/node_modules

          ports:
            - "#{PORTS[:RAILS]}:#{PORTS[:RAILS]}"
            - "#{PORTS[:WEBPACKER]}:#{PORTS[:WEBPACKER]}"

          depends_on:
            - db

        db:
          image: postgres:#{POSTGRES_VERSION}
          environment:
            POSTGRES_PASSWORD: #{DATABASE_PASSWORD}
          volumes:
            - db_data:/var/lib/postgresql/data


      volumes:
        db_data:
        node_modules:

    EOF
  end

  create_file FILES[:DOCKER_IGNORE] do
    <<~EOF
      # Ignore bundler config.
      /.bundle

      # Ignore all logfiles and tempfiles.
      /log/*
      /tmp/*
      !/log/.keep
      !/tmp/.keep

      # Ignore pidfiles, but keep the directory.
      /tmp/pids/*
      !/tmp/pids/
      !/tmp/pids/.keep

      # Ignore uploaded files in development.
      /storage/*
      !/storage/.keep

      /public/assets
      .byebug_history

      # Ignore master key for decrypting credentials and more.
      /config/master.key

      /public/packs
      /public/packs-test
      /node_modules
      !/node_modules/.yarn-integrity
      /yarn-error.log
      yarn-debug.log*
      .git
    EOF
  end

  create_file FILES[:ENTRYPOINT_SCRIPT] do
    <<~EOF
      #!/bin/bash

      set -e

      # Remove a potentially pre-existing server.pid for Rails.
      rm -f /myapp/tmp/pids/server.pid

      # Then exec the container's main process (what's set as CMD in the Dockerfile).
      exec "$@"
    EOF
  end

  create_file FILES[:DATABASE_FILE] do
    <<~EOF
      default: &default
        adapter: postgresql
        encoding: unicode
        host: db
        username: <%= ENV['POSTGRES_USER'] %>
        password: <%= ENV['POSTGRES_PASSWORD'] %>
        pool: 5

      development:
        <<: *default
        database: myapp_development


      test:
        <<: *default
        database: myapp_test
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
