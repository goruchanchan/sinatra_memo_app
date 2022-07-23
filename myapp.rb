#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pg'
require 'rack'
require 'sinatra'
require 'sinatra/reloader'

class DBconection
  @@conn = PG::Connection.new(dbname: 'memoDB', user: 'hoge', password: 'hogehoge')

  def self.run_sql(sentences, options = nil)
    @@conn.exec(sentences, options)
  end
end

def parse_sql(type)
  {
    all: 'SELECT * FROM memos',
    detail: 'SELECT * FROM memos WHERE memo_id = $1',
    write: 'INSERT INTO memos(title, content) VALUES ($1,$2) RETURNING memo_id',
    update: 'UPDATE memos SET (title, content) = ($1,$2) WHERE memo_id = $3 RETURNING memo_id',
    delete: 'DELETE FROM memos WHERE memo_id = $1'
  }[type]
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
  id = DBconection.run_sql(parse_sql(:write), [params['name'], params['content']]).first['memo_id']
  redirect to("/memos/#{id}")
end

put '/memos/:id' do
  DBconection.run_sql(parse_sql(:update), [params['name'], params['content'], @params[:id]]).first['memo_id']
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
