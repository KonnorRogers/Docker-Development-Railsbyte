# frozen_string_literal: true

require_relative 'environment_variables'

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
  @ruby_version = get_env_var(:RUBY_VERSION)
  @node_version = get_env_var(:NODE_VERSION) || '12'
  @rails_port = get_env_var(:RAILS_PORT) || '3000'
  @webpacker_port = get_env_var(:WEBPACKER_PORT) || '3035'
end

def set_postgres_defaults
  @postgres_version = get_env_var(:DOCKER_POSTGRES_VERSION) || '12'
  @postgres_user = get_env_var(:DOCKER_POSTGRES_USER) || 'postgres'
  @postgres_password = get_env_var(:DOCKER_POSTGRES_PASSWORD) || 'EXAMPLE'
end

# Abstracted away due to rubocop complaint
def set_docker_user_defaults
  @user_id =  get_env_var(:DOCKER_USER_ID) || Process.uid || 1000
  @group_id = get_env_var(:DOCKER_GROUP_ID) || Process.gid || 1000
  @username = get_env_var(:DOCKER_USERNAME) || 'user'
end

def set_docker_defaults
  set_docker_user_defaults
  @app_dir = get_env_var(:DOCKER_APP_DIR) || '/myapp'
end

def set_defaults
  set_file_defaults
  set_rails_runtime_defaults
  set_postgres_defaults
  set_docker_defaults
end

# def get_all_defaults
#   return {
#   @files
#   @ruby_version
#   @node_version
#   @rails_port
#   @webpacker_port

#   @postgres_version
#   @postgres_user
#   @postgres_password
#   @user_id
#   @group_id
#   @username
#   @app_dir
#   }
# end
