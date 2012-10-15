require 'test_helper'

class TestClient < MiniTest::Unit::TestCase

  class Widget
    include Alke::Client

    host 'http://localhost:4567'
    path '/widgets'
  end

  def setup
    @client = Object.new
    @class = @client.singleton_class
    @class.send :include, Alke::Client
  end

  def test_default_adapter
    assert_equal Faraday::Adapter::NetHttp, @class.adapter
  end

  def test_default_host
    assert_equal nil, @class.host
  end

  def test_default_prefix
    assert_equal nil, @class.prefix
  end

  def test_default_path
    assert_equal nil, @class.path
  end

  def test_default_url
    assert_equal '', @class.url
    assert_equal '/1', @class.url(1)
  end

  def test_set_host
    @class.host 'http://localhost:4567'
    assert_equal 'http://localhost:4567', @class.host
  end

  def test_connection
    assert @class.connection
    assert @class.connection != @class.connection, 
      "should return a dup'd copy of the connection"
  end

end
