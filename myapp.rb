#!/usr/bin/env ruby
# frozen_string_literal: true


require 'pg'
require 'rack'
require 'sinatra'
require 'sinatra/reloader'

class DBconection
  @@conn = PG::Connection.new(:dbname => 'memoDB')

  def self.run_sql(sentences, options = nil)
    @@conn.exec(sentences,options)
  end
end

def parse_sql(id: nil, name: nil, content: nil, type:nil)
  case type
  when 'all'
    return "SELECT * FROM memos"
  when 'detail'
    return "SELECT * FROM memos WHERE memo_id = #{id}"
  when 'write'
    return "INSERT INTO memos(title, content) VALUES ('#{name}','#{content}') RETURNING memo_id"
  when 'update'
    return "UPDATE memos SET (title, content) = ('#{name}','#{content}') WHERE memo_id = #{id} RETURNING memo_id"
  else
    return "DELETE FROM memos WHERE memo_id = #{id}"
  end
end

def sanitizing_text(text)
  Rack::Utils.escape_html(text)
end

get '/' do
  @title = 'TOP'
  erb :index
end

get '/memos' do
  @title = 'new content'
  erb :new
end

post '/memos' do
  id = DBconection.run_sql(parse_sql(name: params['name'], content: params['content'], type: 'write')).first['memo_id']
  redirect to("/memos/#{id}")
end

put '/memos/:id' do
  id = DBconection.run_sql(parse_sql(id: params['id'], name: params['name'], content: params['content'], type: 'update')).first['memo_id']
  redirect to("/memos/#{params['id']}")
end

get '/memos/:id' do
  @title = 'show content'
  erb :show
end

get '/memos/:id/edit' do
  @title = 'edit'
  erb :edit
end

delete '/memos/:id' do
  @title = 'delete'
  erb :delete
end
