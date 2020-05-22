# frozen_string_literal: true

require_relative 'environment_variables'

def ruby_version_ask(ruby_version)
  question = "\nWhat version of Ruby would you like in your Dockerfile?"
  format = '[2.7, 2.7.1, 2.7.2 etc]'
  note = "\nBe aware, if this does not match the Ruby Version in your Gemfile" \
         ' you will encounter errors'

  current = "\nYou are currently using: ruby"

  str = "#{question} #{format} #{current}"

  say note, :red
  print str

  ask('', default: ruby_version)
end

def node_version_ask(node_version)
  question = "\nWhat version of Node would you like to use in your Dockerfile?"
  format = '[12, 11, 10, etc]'

  current = "\nThe default node is:"
  print("#{question} #{format} #{current}")

  ask('', default: node_version)
end

def bundler_version_ask(bundler_version)
  question = "\nWhat version of Bundler would you like to use?"
  format = '[2.14, 2.10, etc]'
  current = "\nWe detected bundler version:"
  note = "\nMake sure this is the same as the BUNDLED_WITH value in your Gemfile.lock"

  say note, :red
  str = "#{question} #{format} #{current}"
  print str
  ask('', default: bundler_version)
end

def port_ask(port, service)
  question = "\nWhat port would you like to use for #{service}?"
  format = '[3000, 3035, 8000, 8080, etc]'

  print "#{question}\n#{format}\nThe default port is:"
  ask('', default: port)
end

def rails_port_ask(rails_port)
  port_ask(rails_port, 'Rails')
end

def webpacker_port_ask(webpacker_port)
  port_ask(webpacker_port, 'Webpacker')
end

def postgres_version_ask(version)
  note = "\nPlease make sure the version you pick exists here: https://hub.docker.com/_/postgres\n"
  question = 'What version of postgres would you like to use?'
  format = '[12, 11, 10, etc]'
  print "#{note} #{question} #{format}\nThe default is:"

  ask('', default: version)
end

def postgres_user_ask(username)
  question = 'What would you like to use as your Postgres username?'
  format = "[supercoolguy, databaseadmin, etc]\n"
  note = "Be aware, there are issues with changing the Postgres username\n" \
         "visit https://hub.docker.com/_/postgres for full details\n"

  say note, :red
  print "#{question} #{format} the default is:"
  ask('', default: username)
end

def postgres_password_ask(password)
  question = "\nWhat password would you like to use for postgres?"
  format = "[password1, password2, etc]\n"
  print "#{question} #{format} the default is set to:"

  # Set echo to false so you cant see the user's password
  postgres_password = ask('', default: password, echo: false)
  set_env_var(:DOCKER_POSTGRES_PASSWORD, postgres_password)
end

def username_ask(username)
  question = "\nWhat username would you like to use?\n"
  format = '[user, super-cool-guy, etc]'
  print "#{question} #{format}\nThe default is:"
  ask('', default: username)
end

def app_dir_ask(app_dir)
  note = %(\nThe directory you specify will append to the value given for user)
  question = 'Where would you like your app saved in your Dockerfile?'
  format = '[/myapp, /rails-app, etc]'

  print "#{note} #{question} #{format} the default is: "

  ask('', default: app_dir)
end

def id_ask(id, type)
  question = "What #{type}_id would you like to use?"
  format = '[1000, 2000, 3000, etc]'
  print "#{question} #{format}\nWe detected your current #{type}_id is: "
  ask('', default: id)
end

def user_id_ask(user_id)
  id_ask(user_id, :user)
end

def group_id_ask(group_id)
  id_ask(group_id, :group)
end
