# frozen_string_literal: true

def ruby_version_ask(ruby_version)
  question = "\nWhat version of Ruby would you like in your Dockerfile?"
  format = '[2.7, 2.7.1, 2.7.2 etc]'
  note = "\nBe aware, if this does not match the Ruby Version in your Gemfile" \
         ' you will encounter errors'

  current = "\nYou are currently using: ruby"

  str = "#{note} #{question} #{format} #{current}"

  print str
  ask('', default: ruby_version)
end

def node_version_ask(node_version)
  question = '\nWhat version of Node would you like to use in your Dockerfile?'
  format = '[12, 11, 10, etc]'

  current = "\nYou are currently using: node:"
  print("#{question} #{format} #{current}")

  ask('', default: node_version)
end

def port_ask(port, service)
  question = "\nWhat port would you like to use for #{service}?"
  format = '[3000, 3035, 8000, 8080, etc]'

  print "#{question} #{format} the default port is:"
  ask('', default: port)
end

def rails_port_ask(rails_port)
  port_ask(rails_port, 'Rails')
end

def webpacker_port_ask(webpacker_port)
  port_ask(webpacker_port, 'Webpacker')
end

def postgres_version_ask(version)
  note = "\nPlease make sure the version you pick exists here: https://hub.docker.com/_/postgres"
  question = 'What version of postgres would you like to use?'
  format = '[12, 11, 10, etc]'
  print "#{note} #{question} #{format} the default is:"

  ask('', default: version)
end

def postgres_password_ask(password)
  question = "\nWhat password would you like to use for postgres?"
  format = '[password1, password2, etc]'
  print "#{question} #{format} the default is set to:"
  ask('', default: password)
end

def postgres_user_ask(username)
  question = 'What would you like to use as your Postgres username?'
  format = '[supercoolguy, databaseadmin, etc]'
  note = "\nBe aware, there are issues with changing the Postgres username\n
          visit https://hub.docker.com/_/postgres for full details"

  print "#{note} #{question} #{format} the default is:"
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
  print "#{question} #{format}\nThe default is: "
  ask('', default: id)
end

def user_id_ask(user_id)
  id_ask(user_id, :user)
end

def group_id_ask(group_id)
  id_ask(group_id, :group)
end

def username_ask(username)
  question = "What username would you like to use?\n"
  format = '[user, super-cool-guy, etc]'
  print "#{question} #{format}\nThe default is:"
  ask('', default: username)
end
