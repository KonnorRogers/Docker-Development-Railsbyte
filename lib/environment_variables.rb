# frozen_string_literal: true

ENV_VARS = {
  RUBY_VERSION: 'RUBY_VERSION',
  NODE_VERSION: 'NODE_VERSION',
  BUNDLER_VERSION: 'BUNDLER_VERSION',
  RAILS_PORT: 'RAILS_PORT',
  WEBPACKER_PORT: 'WEBPACKER_PORT',
  DOCKER_POSTGRES_VERSION: 'DOCKER_POSTGRES_VERSION',
  DOCKER_POSTGRES_USER: 'DOCKER_POSTGRES_PASSWORD',
  DOCKER_POSTGRES_PASSWORD: 'DOCKER_POSTGRES_PASSWORD',
  DOCKER_GROUP_ID: 'DOCKER_GROUP_ID',
  DOCKER_USER_ID: 'DOCKER_USER_ID',
  DOCKER_USERNAME: 'DOCKER_USERNAME',
  DOCKER_APP_DIR: 'DOCKER_APP_DIR'
}.freeze

# Prints the env key & its ENV["#{value}"]
def print_env_vars
  ENV_VARS.each { |key, value| puts "#{key}: #{ENV[value]}" }
end

# Returns the values of ENV[#{value}]
def get_env_var(var)
  ENV[ENV_VARS[var]]
end

# Set an environment variable
def set_env_var(var, value)
  ENV[ENV_VARS[var]] = value
end
