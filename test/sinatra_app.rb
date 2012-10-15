require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sequel'

DB ||= Sequel.sqlite
DB.create_table? :widgets do
  primary_key :id
  String :name
  Integer :price
  Boolean :stock
  DateTime :updated_at
end
class Widget < Sequel::Model; plugin :json_serializer, naked: true; end
Widget.find_or_create(name: 'WonderKnife', price: 1000, \
  stock: true, updated_at: Time.utc(2012, 1, 15, 13, 30))

disable :show_exceptions
before '/widget*' do
  content_type :json
end

get '/', provides: :html do
  'Alke Sinatra Testing App - There is a widgets resource here at /widgets!'
end

get '/widgets/?', provides: [:json, :html] do
  Widget.all.to_json
end

get '/widgets/:id', provides: [:json, :html] do |id|
  Widget[id].to_json
end

post '/widgets/?', provides: :json do
  data = JSON.parse(request.body.read)
  Widget.create(data.merge(updated_at: Time.now)).to_json
end

put '/widgets/:id', provides: :json do |id|
  data = JSON.parse(request.body.read)
  Widget[id].update(data.merge(updated_at: Time.now)).to_json
end

delete '/widgets/:id', provides: :json do |id|
  Widget[id].destroy
end
