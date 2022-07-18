#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class DBconection
  @@conn = PG::Connection.new(:dbname => 'memoDB')

  def self.run_sql(sentences, options = nil)
    @@conn.exec(sentences,options)
  end
end

def parse_memo_detail(id)
  DBconection.run_sql("SELECT * FROM memos WHERE memo_id = #{id}").first
end

def write_memo(name, content)
  DBconection.run_sql("INSERT INTO memos(title, content) VALUES ($1,$2) RETURNING memo_id",[name,content]).first
end

def update_memo(id, name, content)
  DBconection.run_sql("UPDATE memos SET (title, content) = ($1, $2) WHERE memo_id = $3 RETURNING memo_id",[name,content,id]).first
end

def delete_memo(id)
  DBconection.run_sql("DELETE FROM memos WHERE memo_id = $1",[id]).first
end

def sanitizing_text(text)
  text.gsub(/&|<|>|"|'/, '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;', "\'" => '&#39;')
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
  id = update_memo(params['id'], params['name'], params['content'])['memo_id']
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
  erb :delete
end
