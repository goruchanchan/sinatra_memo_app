# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

def load_memo_path
  './public/memos/'
end

def parse_memo_detail(id)
  f = File.new("#{load_memo_path}#{id}/name.txt")
  name = f.gets
  f = File.new("#{load_memo_path}#{id}/content.txt")
  content = f.gets
  { id: id, name: name, content: content }
end

def parse_memo_directories
  Dir.open(load_memo_path.to_s).children.reject { |dir_name| dir_name.include? 'del' }
end

def create_memo_directory
  id = Dir.open(load_memo_path.to_s).children.size + 1
  Dir.mkdir("#{load_memo_path}#{id}", 0o0777)
  id
end

def write_memo(id, name, content)
  IO.write("#{load_memo_path}#{id}/name.txt", name.to_s)
  IO.write("#{load_memo_path}#{id}/content.txt", content.to_s)
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
  id = create_memo_directory
  write_memo(id, params['name'], params['content'])
  redirect to("/show/#{id}")
end

put '/new/:id' do
  write_memo(params['id'], params['name'], params['content'])
  redirect to("/show/#{params['id']}")
end

get '/show/:id' do
  @title = 'show content'
  @memo_info = parse_memo_detail(params['id'])
  erb :show
end

put '/:id/edit' do
  @title = 'edit'
  @memo_info = parse_memo_detail(params['id'])
  erb :edit
end

delete '/:id/delete' do
  @title = 'delete'
  @memo_info = parse_memo_detail(params['id'])
  delete_memo(params['id'])
  erb :delete
end
