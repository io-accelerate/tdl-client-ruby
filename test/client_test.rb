require 'test_helper'

class ClientTest < MiniTest::Unit::TestCase
  def test_english_hello
    assert_equal "hello world",
                 TDL::Client.hi("english")
  end

  def test_any_hello
    assert_equal "hello world",
                 TDL::Client.hi("ruby")
  end

  def test_spanish_hello
    assert_equal "hola mundo",
                 TDL::Client.hi("spanish")
  end
end