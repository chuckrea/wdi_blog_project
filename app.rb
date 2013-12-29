require 'bundler/setup'
Bundler.require(:default)

require_relative 'models/post'
require_relative 'models/user'
require_relative 'models/comment'
require_relative 'models/like'
require_relative 'config'

enable :sessions

get '/' do
	if session[:username]
		@user = User.find_by_username(session[:username])
	else 
		@user = nil
	end

	@posts = Post.all

	erb :index
end

get '/posts' do

redirect '/'
end

post '/posts' do
  title = params[:title]
  body = params[:body]
  unless params[:language] == "nil"
    language = params[:language]
    code_body = CodeRay.scan(body, language).div(:line_numbers => :table)
    post = Post.new(:title => title, :body => code_body)
  else
    post = Post.new(:title => title, :body => body)
  end
  
  user = User.find_by_username(session[:username])
  user.posts << post
  post.save
  redirect '/'
end

get '/posts/:id/edit' do

@post = Post.find(params[:id])
erb :edit_post

end

post '/posts/:id/edit' do
  @user = User.find_by_username(session[:username])
  post = Post.find(params[:id])
  unless params[:language] == "nil"
    language = params[:language]
    code_body = CodeRay.scan(params[:body], language).div(:line_numbers => :table)
    post.title = params[:title]
    post.body = code_body
  else
    post.title = params[:title]
    post.body = params[:body]
  end

  post.save

  erb :show
end

get '/posts/:id/delete' do
  post = Post.find(params[:id])
  post.destroy

  @user = User.find_by_username(session[:username])
  erb :show

end


get '/users/sign_up' do 
	erb :sign_up
end

post '/users' do 
	user = User.create(:username => params[:username])
	session[:username] = user.username
	redirect '/'
end

get '/users/sign_in' do 
	erb :sign_in
end

post '/users/sign_in' do 
  if user = User.find_by_username(params[:username])
  	session[:username] = user.username
  	redirect '/'
  else 
  	redirect '/users/sign_up'
  end
end

get '/users/sign_out' do 
	session[:username] = nil
	redirect '/'
end

get '/users/:id' do 
	@user = User.find(params[:id].to_i)

	erb :show
end

post '/posts/:id/comments' do 
	user = User.find_by_username(session[:username])
	post = Post.find(params[:id].to_i)
	comment = Comment.new(:body => params[:comment_text])
	comment.save 
	post.comments << comment
	user.comments << comment
	redirect '/'
end 

get '/posts/:id/like' do 

	
	user = User.find_by_username(session[:username])
	post = Post.find(params[:id].to_i)

	# like = Like.create
	# like.user = user
	# like.post = post
	# like.save

	user.faves << post

	redirect '/'

end

get '/posts/:id/unlike' do

user = User.find_by_username(session[:username])
post = Post.find(params[:id].to_i)
user.faves.delete(post)

redirect '/'


end



















