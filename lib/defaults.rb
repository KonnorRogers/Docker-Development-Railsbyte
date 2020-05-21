# frozen_string_literal: true

def set_file_defaults
  @files = {
    dockerfile: 'Dockerfile.dev',
    docker_compose: 'docker-compose.yml',
    docker_ignore: '.dockerignore',
    entrypoint_script: 'entrypoint.sh',
    database_files: 'config/database.yml'
  }
end

def set_rails_runtime_defaults
  # User has to be running Ruby to use this
  @ruby_version = RUBY_VERSION
  @node_version = ENV['NODE_VERSION'] || '12'
  @rails_port = ENV['RAILS_PORT'] || '3000'
  @webpacker_port = ENV['WEBPACKER_PORT'] || '3035'
end

def set_postgres_defaults
  @postgres_version = ENV['DOCKER_POSTGRES_VERSION'] || '12'
  @postgres_user = ENV['DOCKER_POSTGRES_USER'] || 'postgres'
  @postgres_password = ENV['DOCKER_POSTGRES_PASSWORD'] || 'EXAMPLE'
end

# Abstracted away due to rubocop complaint
def set_docker_user_defaults
  @user_id =  ENV['DOCKER_USER_ID'] || Process.uid || 1000
  @group_id = ENV['DOCKER_GROUP_ID'] || Process.gid || 1000
  @username = ENV['DOCKER_USERNAME'] || 'user'
end

def set_docker_defaults
  set_docker_user_defaults
  @app_dir = ENV['DOCKER_APP_DIR'] || '/myapp'
end

def set_defaults
  set_file_defaults
  set_rails_runtime_defaults
  set_postgres_defaults
  set_docker_defaults
end
