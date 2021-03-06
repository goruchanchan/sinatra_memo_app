# frozen_string_literal: true

require 'json'
require 'rack'
require 'sinatra'
require 'sinatra/reloader'

def load_memo_path
  './db/'
end

def parse_memo_detail(file_name)
  f = File.new("#{load_memo_path}#{file_name}")
  hash = JSON.parse(f.gets)
  { id: hash['id'], name: hash['name'], content: hash['content'] }
end

def parse_memo_files
  Dir.open(load_memo_path.to_s).children.reject { |file_name| file_name.include? 'del' }
end

def write_memo(id, name, content)
  IO.write("#{load_memo_path}#{id}.json", JSON.dump({ id: id, name: name, content: content }))
end

def sanitizing_text(text)
  Rack::Utils.escape_html(text)
end

def delete_memo(file_name)
  File.rename("#{load_memo_path}#{file_name}", "#{load_memo_path}#{file_name}.del")
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
  id = Dir.open(load_memo_path).children.size + 1
  write_memo(id, params['name'], params['content'])
  redirect to("/memos/#{id}")
end

put '/memos/:id' do
  write_memo(params['id'], params['name'], params['content'])
  redirect to("/memos/#{params['id']}")
end

get '/memos/:id' do
  @title = 'show content'
  @memo_info = parse_memo_detail("#{params['id']}.json")
  erb :show
end

get '/memos/:id/edit' do
  @title = 'edit'
  @memo_info = parse_memo_detail("#{params['id']}.json")
  erb :edit
end

delete '/memos/:id' do
  @title = 'delete'
  @memo_info = parse_memo_detail("#{params['id']}.json")
  delete_memo("#{params['id']}.json")
  erb :delete
end
