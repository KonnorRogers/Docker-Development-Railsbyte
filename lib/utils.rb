# frozen_string_literal: true

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def minimum_rails_version?(min, max)
  return Gem::Requirement.new(min).satisfied_by? rails_version if max.nil?

  Gem::Requirement.new(min, max).satisfied_by? rails_version
end

def assert_minimum_rails_version(version, min, max)
  return if max.nil? && minimum_rails_version(min)
  return if minimum_rails_version(min, max)

  prompt = "This template requires Rails #{version}. "\
           "You are using #{version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# The only way to be running rails is with the proper RUBY_VERSION, so no
# need to parse the lockfile.
def ruby_version
  @ruby_version ||= RUBY_VERSION
end

def minimum_ruby_version(version)
  Gem::Requirement.new(version).satisfied_by? ruby_version
end

def assert_minimum_ruby_version
  return if minimum_ruby_version

  prompt = "This template requires Ruby #{ruby_version}. "\
           "You are using #{ruby_version}. Continue anyway?"
  exit 1 if no?(prompt)
end
