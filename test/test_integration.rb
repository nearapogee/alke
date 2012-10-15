require 'test_helper'

class TestIntegration < MiniTest::Unit::TestCase

  class Widget
    include Alke::Client

    host 'http://localhost:4567'
    path '/widgets'

    schema do
      id :primary_key
      name :string
      price :integer
      stock :boolean
      updated_at :datetime, readonly: true
    end
  end

  class ::Md5Signature < Faraday::Middleware
    def call(env)
      @app.call(env)
    end
  end

  def setup
    $live_warning ||= false
    unless ENV['LIVE'] == '1'
      unless $live_warning 
        msg =  "\nStart the server `ruby test/sinatra_app.rb` and set "
        msg += "the LIVE=1 env variable."
        puts msg
        $live_warning = true
      end
      skip
    end
  end

  def test_find
    assert w = Widget[1]
    assert_equal Widget, w.class
    assert_equal 1, w.id
  end

  def test_responds_to
    w = Widget.new
    assert w.respond_to? :id
    assert w.respond_to? :name
    assert w.respond_to? :price
    assert w.respond_to? :stock
    assert w.respond_to? :updated_at
    assert !w.respond_to?(:id=)
    assert w.respond_to? :name=
    assert w.respond_to? :price=
    assert w.respond_to? :stock=
    assert !w.respond_to?(:updated_at=)
  end

  def test_responds_to_schemaless
    w = Widget.new quantity: 6
    assert w.respond_to? :quantity
    assert !w.respond_to?(:quantity=)
    w2 = Widget.new
    assert !w2.respond_to?(:quantity)
  end

  def test_save_new
    w = Widget.new(name: "WonderDog", price: 10100, stock: false)
    w.save
    assert w.persisted?
    assert Widget[w.id]
  end

  def test_save_persisted
    w = Widget[1]
    w.name = "WonderSaw"
    w.save
    assert_equal "WonderSaw", w.name
    w = Widget[1]
    assert_equal "WonderSaw", w.name
  end

  def test_reload
    w1 = Widget[1]
    w2 = Widget[1]
    new_stock = !w2.stock
    w2.stock = new_stock
    w2.save
    assert w2.stock != w1.stock
    assert_equal true, w1.reload
    assert_equal w2.stock, w1.stock
  end

  def test_reload_failed_request
    w = Widget[1]
    def w.url
      "/wrong/1"
    end
    assert_equal false, w.reload
    assert w.id
  end

  def test_reload_new
    w = Widget.new
    assert_equal false, w.reload
  end

  def test_save_with_middleware
    w = Widget[1]
    new_price = w.price * 2
    w.price = new_price
    w.save do |c|
      with Md5Signature
    end
    assert_equal new_price, w.price
    assert w.connection.builder.handlers.include?(::Md5Signature)
    w.reload
    assert_equal new_price, w.price
  end

  def test_create
    w = Widget.create(name: 'WonderRug', price: 2000, stock: true)
    assert w.id
    assert w.persisted?
  end

  def test_create_with_middleware
    skip
    w = Widget.create(name: 'WonderDrug', price: 10000, stock: true) do |c|
      with Md5Signature
    end
    assert w.persisted?
    assert_equal Widget.connection.middleware, w.connection.middleware
    assert !w.connection.middleware.include?(Md5Signature)
  end

  def test_update
    skip
    w = Widget[1]
    new_name = w.name + "(tm)"
    w.update(name: new_name)
    assert_equal new_name, w.name
    w.reload
    assert_equal new_name, w.name
  end

  def test_update_with_middleware
    skip
    w = Widget[1]
    new_name = w.name + "(tm)"
    w.update(name: new_name) do |c|
      with Md5Signature
    end
    assert_equal new_name, w.name
    w.reload
    assert_equal new_name, w.name
  end

  def test_destroy
    skip
    w = Widget.last
    w.destroy
    assert !Widget[w.id]
    assert !Widget.exists?(w.id)
  end
end
