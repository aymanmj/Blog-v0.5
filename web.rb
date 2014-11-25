require 'sinatra'
require 'sequel'
require 'sinatra/flash'
require 'rdiscount'

enable :sessions


DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres:56223911@localhost:5432/blogs')

Username = "admin"
Password = "admin"

get '/' do
    @blogs = DB[:blogs].all.reverse
    erb :index
end

get '/blog/:id' do
    @blog = DB[:blogs].where(:id => params[:id]).first
    
    erb :blog
end


before '/admin*' do
    if session[:is_login] != true
        redirect '/login'
    end
end


get '/admin' do
    @blogs = DB[:blogs].all
    erb :admin
end

get '/admin/add_blog' do
    erb :admin_add_blog
end

post '/admin/add_blog' do
    title = params[:title]
    summary = params[:summary]
    content = params[:content]
    
    DB[:blogs].insert(:title => title, :summary => summary, 
    :content => content)
    
    flash[:notice] = 'تمت إضافة التدوينة بنجاح'
    redirect '/admin'
end

get '/admin/edit_blog/:id' do
    @blog = DB[:blogs].where(:id => params[:id]).first
    erb :admin_edit_blog
end

post '/admin/edit_blog/:id' do
    title = params[:title]
    summary = params[:summary]
    content = params[:content]
    
    DB[:blogs].where(:id => params[:id]).update(:title => title,
                                               :summary => summary,
                                               :content => content)
    flash[:notice] = 'تم تعديل التدوينة بنجاح'
    redirect '/admin'
end

get '/admin/delete_blog/:id' do
    DB[:blogs].where(:id => params[:id]).delete
    redirect '/admin'
end

get '/login' do
    erb :login
end

post '/login' do
    if params[:username] == Username and params[:password] == Password
        session[:is_login] = true
        redirect '/admin'
    else
        @error = true
        erb :login
    end
end

get '/logout' do
    session[:is_login] = false
    redirect '/'
    
end