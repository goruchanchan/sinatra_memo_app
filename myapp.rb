#!/usr/bin/env ruby
# frozen_string_literal: true

Bundler.require(:default)

class DBConnection
  def initialize
    @conn = PG::Connection.new(dbname: 'memoDB', user: 'hoge', password: 'hogehoge')
  end

  def run_sql(sentences, options = nil)
    @conn.exec(sentences, options)
  end

  def self.choose_sql(type)
    {
      all: 'SELECT * FROM memos',
      detail: 'SELECT * FROM memos WHERE memo_id = $1',
      write: 'INSERT INTO memos(title, content) VALUES ($1,$2) RETURNING memo_id',
      update: 'UPDATE memos SET (title, content) = ($1,$2) WHERE memo_id = $3 RETURNING memo_id',
      delete: 'DELETE FROM memos WHERE memo_id = $1'
    }[type]
  end
end

def sanitizing_text(text)
  Rack::Utils.escape_html(text)
end

dbcon = DBConnection.new

get '/' do
  @title = 'TOP'
  @all_memo_info = dbcon.run_sql(DBConnection.choose_sql(:all))
  erb :index
end

get '/memos' do
  @title = 'new content'
  erb :new
end

post '/memos' do
  id = dbcon.run_sql(DBConnection.choose_sql(:write), [params['name'], params['content']]).first['memo_id']
  redirect to("/memos/#{id}")
end

put '/memos/:id' do
  dbcon.run_sql(DBConnection.choose_sql(:update), [params['name'], params['content'], params[:id]]).first['memo_id']
  redirect to("/memos/#{params[:id]}")
end

get '/memos/:id' do
  @title = 'show content'
  @memo_info = dbcon.run_sql(DBConnection.choose_sql(:detail), [params[:id]]).first
  erb :show
end

get '/memos/:id/edit' do
  @title = 'edit'
  @memo_info = dbcon.run_sql(DBConnection.choose_sql(:detail), [params[:id]]).first
  erb :edit
end

delete '/memos/:id' do
  @title = 'delete'
  @memo_info = dbcon.run_sql(DBConnection.choose_sql(:detail), [params[:id]]).first
  dbcon.run_sql(DBConnection.choose_sql(:delete), [params[:id]])
  erb :delete
end
