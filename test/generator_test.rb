# frozen_string_literal: true

require 'minitest/autorun'

# Taken from https://github.com/excid3/jumpstart/blob/master/test/template_test.rb
class GeneratorTest < Minitest::Test
  def setup
    system('[ -d test_app ] && rm -rf test_app')
  end

  def teardown
    setup
  end

  def test_generator_succeeds
    output, err = capture_subprocess_io do
      system('DISABLE_SPRING=1 rails new -m "generator.rb" test_app')
    end
    assert_includes output, 'Successfully added Docker to your project!'
  end
end
