require 'sinatra'
require 'sinatra/activerecord'
set :database, 'sqlite3:rumblr.sqlite3'
set :sessions, true
require './models'

def user_logged_in
	if session[:user_id]
		@active_user = User.find(session[:user_id])
	end
end

# Homepage
# ("/")
get "/" do
	@blogs = Blog.all
	erb :home
end

# Show list of all users - clicking on user brings viewer to a page of that user's most recent 20 blog posts
# ("/users")
get "/users" do
	@users = User.all
	erb :allusers
end

# User's most recent 20 blog posts
# ("/users/view/:id")
get "/users/view/:id" do
	@viewuser = User.find(params[:id])
	@userblogs = Blog.where(user_id: params[:id])
	erb :userblogs
end

# Sign-up Page
# ("/signup")
get "/signup" do
	erb :signup
end

# POST: Sign-up Form
post "/signup" do
  username = params[:username]
  password = params[:password]
	firstname = params[:firstname]
	lastname = params[:lastname]
  birthday = params[:birthday]
  email = params[:email]

  if User.create(username: username, password: password, birthday: birthday, email: email, firstname: firstname, lastname: lastname)
    redirect "/"
  else
    erb :testhello
  end
end

# Log-in Page
# ("/login")
get "/login" do
	erb :login
end

# POST: Log-in Form
post "/login" do
	username = params[:username]
	password = params[:password]

	user = User.where(username: username).first

	if user.password == password
		session[:user_id] = user.id
		redirect "/users/#{user.id}"
	else
		redirect "/"
	end
end

# Successful log-in redirects to user profile page
# ("/users/:id")
get "/users/:id" do
	p session[:user_id]

	@currentuser = User.find(params[:id])
	@blogs = Blog.where(user_id: session[:user_id])

	erb :userprofile
end

# Edit User Information Page
# ("/users/:id/edit")
get "/users/:id/edit" do
	@currentuser = User.find(params[:id])
	erb :edituser
end

# POST: Update a user's information
post "/users/:id/update" do
	firstname = params[:firstname]
	lastname = params[:lastname]
	birthday = params[:birthday]
	email = params[:email]
	currentuser = User.find(params[:id])

	if currentuser.update(firstname: firstname, lastname: lastname, birthday: birthday, email: email)
		redirect "/users/#{currentuser.id}"
	else
		erb "/users/<% currentuser.id %>/edit"
	end
end

# POST: Update a user's password
post "/users/:id/updatepassword" do
	currentuser = User.find(params[:id])
	currentpassword = params[:currentpassword]
	newpassword1 = params[:newpassword1]
	newpassword2 = params[:newpassword2]

	if currentpassword == currentuser.password && newpassword1 == newpassword2
		currentuser.update(password: newpassword1)
		redirect "/users/#{currentuser.id}"
	else
		erb "/users/<% currentuser.id %>/edit"
	end
end

# POST: Delete a user
post "/destroy/:id" do
	currentuser = User.find(params[:id])
	userblogs = Blog.where(user_id: params[:id])
	passwordcheck = params[:destroycheck]

	if passwordcheck == currentuser.password
		if currentuser.destroy
			userblogs.each do |blog|
				blog.destroy
			end
			session[:user_id] = nil
			redirect "/"
		else
			erb :testhello
		end
	else
		redirect "/users/#{currentuser.id}"
	end
end

# New blog post
# ("/newblog")
get "/newblog" do
  erb :newblog
end

# POST: Create a blog post
post "/create_blog" do
	if !session[:user_id]
		erb :testhello
	else
	  title = params[:title]
	  content = params[:content]

		user = User.find(session[:user_id])

	  Blog.create(title: title, content: content, likes: 0, user_id: user.id)

	  redirect "/"
	end
end

# Show a specific blog post
# ("/blogs/:id")
get "/blogs/:id" do
  @blog = Blog.find(params[:id])
	erb :showblog
end

# Edit a specific blog post
# ("/blogs/:id/edit")
get "/blogs/:id/edit" do
	@blog = Blog.find(params[:id])
	erb :editblog
end

# POST: Update a blog post
post "/blogs/:id/update" do
	@blog = Blog.find(params[:id])
	title = params[:title]
	content = params[:content]

	if @blog.update(title: title, content: content)
		redirect "/"
	else
		erb "/blogs/<%= @blog.id %>/edit"
	end
end

# POST: Destroy a blog post
post "/destroy/:id" do
	@blog = Blog.find(params[:id])
	if @blog.destroy
		redirect "/"
	else
		erb :testhello
	end
end

# Log out, redirects to home
get "/logout" do
	session[:user_id] = nil

	redirect "/"
end




#
