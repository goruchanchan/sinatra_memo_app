#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pg'
require 'rack'
require 'sinatra'
require 'sinatra/reloader'

class DBconection
  def initialize
    @conn = PG::Connection.new(dbname: 'memoDB', user: 'hoge', password: 'hogehoge')
  end

  def run_sql(sentences, options = nil)
    @conn.exec(sentences, options)
  end

  def self.parse_sql(type)
    {
      all: 'SELECT * FROM memos',
      detail: 'SELECT * FROM memos WHERE memo_id = $1',
      write: 'INSERT INTO memos(title, content) VALUES ($1,$2) RETURNING memo_id',
      update: 'UPDATE memos SET (title, content) = ($1,$2) WHERE memo_id = $3 RETURNING memo_id',
      delete: 'DELETE FROM memos WHERE memo_id = $1'
    }[type]
  end

  def self.sanitizing_text(text)
    Rack::Utils.escape_html(text)
  end
end

dbcon = DBconection.new

get '/' do
  @title = 'TOP'
  @dbcon = dbcon
  erb :index
end

get '/memos' do
  @title = 'new content'
  @dbcon = dbcon
  erb :new
end

post '/memos' do
  id = dbcon.run_sql(DBconection.parse_sql(:write), [params['name'], params['content']]).first['memo_id']
  @dbcon = dbcon
  redirect to("/memos/#{id}")
end

put '/memos/:id' do
  dbcon.run_sql(DBconection.parse_sql(:update), [params['name'], params['content'], @params[:id]]).first['memo_id']
  @dbcon = dbcon
  redirect to("/memos/#{params['id']}")
end

get '/memos/:id' do
  @title = 'show content'
  @dbcon = dbcon
  erb :show
end

get '/memos/:id/edit' do
  @title = 'edit'
  @dbcon = dbcon
  erb :edit
end

delete '/memos/:id' do
  @title = 'delete'
  @dbcon = dbcon
  erb :delete
end
