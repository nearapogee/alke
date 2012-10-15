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

  def test_create
    w = Widget.create(
      name: 'WonderRug',
      price: 2000,
      stock: true
    )
    assert w.id
    assert w.persisted?
  end
end
