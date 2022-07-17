#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class Memos
  attr_reader :memo_id
  attr_accessor :title, :content

  def initialize(title, content)
    @title = title
    @content = content
  end
end

def select_memos_all
  database = String('memoDB')
  conn = PG::Connection.new(:dbname => database)
  result = conn.exec("SELECT * FROM memos")
end

def load_memo_path
  './public/memos/'
end

def parse_memo_detail(id)
  database = String('memoDB')
  conn = PG::Connection.new(:dbname => database)
  conn.exec("SELECT * FROM memos WHERE memo_id = #{id}").first
end

def parse_memo_directories
  Dir.open(load_memo_path.to_s).children.reject { |dir_name| dir_name.include? 'del' }
end

def write_memo(id = nil, name, content)
  database = String('memoDB')
  conn = PG::Connection.new(:dbname => database)
  sql = id.nil? ? "INSERT INTO memos(title, content) VALUES ($1,$2) RETURNING memo_id" :   "UPDATE memos SET (title, content) = ($1, $2) WHERE memo_id = $3 RETURNING memo_id"
  conn.exec(sql,[name,content,id]).first
end

def sanitizing_text(text)
  text.gsub(/&|<|>|"|'/, '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;', "\'" => '&#39;')
end

def delete_memo(id)
  File.rename("#{load_memo_path}#{id}", "#{load_memo_path}#{id}.del")
end

get '/' do
  @title = 'TOP'
  erb :index
end

get '/new' do
  @title = 'new content'
  erb :new
end

post '/new' do
  id = write_memo(params['name'], params['content'])['memo_id']
  redirect to("/show/#{id}")
end

put '/new/:id' do
  id = write_memo(params['id'], params['name'], params['content'])['memo_id']
  redirect to("/show/#{params['id']}")
end

get '/show/:id' do
  @title = 'show content'
  erb :show
end

put '/:id/edit' do
  @title = 'edit'
  erb :edit
end

delete '/:id/delete' do
  @title = 'delete'
  @memo_info = parse_memo_detail(params['id'])
  delete_memo(params['id'])
  erb :delete
end
