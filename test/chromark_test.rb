require "test_helper"

class ChromarkTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Chromark::VERSION
  end
end
