require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'json'
require 'sinatra/twitter-bootstrap'
require "sinatra-authentication"

use Rack::Session::Cookie, :secret => 'Y0ur s3cret se$$ion key'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/todo_list.db")
  
module Sinatra
  module Helpers
    def use_layout?
      false
    end
  end
end
  
class Item
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :done, Boolean, :required => true, :default => false
  property :created, DateTime
end

DataMapper.finalize.auto_upgrade!

register Sinatra::Twitter::Bootstrap::Assets

get '/?' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
  erb :index
end

get '/new/?' do
  @title = "Add todo item"
  erb :new
end

post '/new/?' do
  Item.create(:content => params[:content], :created => Time.now)
  redirect '/'
end

post '/done/?' do
  item = Item.first(:id => params[:id])
  item.done = !item.done
  item.save
  content_type 'application/json'
  value = item.done ? 'done' : 'not done'
  { :id => params[:id], :status => value }.to_json
end

get '/delete/:id/?' do
  @item = Item.first(:id => params[:id])
  erb :delete
end

post '/delete/:id/?' do
  if params.has_key?("ok")
    item = Item.first(:id => params[:id])
    item.destroy
    redirect '/'
  else
    redirect '/'
  end
end
