# frozen_string_literal: true

require 'rake'
require 'thor'
require 'rake/testtask'
require 'erb'

require_relative 'lib/defaults'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

# https://gist.github.com/metaskills/8691558
# how to use thor actions in a rake task
class Hammer < Thor
  include Thor::Actions
end

# taken from "template.rb"
def copy_templates
  templates = File.join(File.expand_path(__dir__), 'templates')

  Hammer.source_root(File.join('templates', 'erb'))

  @files.values.each do |file|
    dest_file = File.join(templates, 'default', file)
    source_file = ERB.new(File.read(File.join(templates, 'erb', file))).result(binding)
    hammer :create_file, dest_file, source_file
  end
end

desc 'update default templates'
task :update_default_templates do |_t|
  set_defaults
  copy_templates
end

private

def hammer(*args)
  Hammer.new.send(*args)
end
