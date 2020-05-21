# frozen_string_literal: true

require 'test_helper'

# Taken from https://github.com/excid3/jumpstart/blob/master/test/template_test.rb
class TemplateTest < Minitest::Test
  def setup
    system('[ -d test_app ] && rm -rf test_app')
  end

  def teardown
    setup
  end

  def test_generator_succeeds
    output, err = capture_subprocess_io do
      system('DISABLE_SPRING=1 rails new -m "template.rb" test_app')
    end
    assert_includes output, 'Successfully added Docker to your project!'
  end
end
