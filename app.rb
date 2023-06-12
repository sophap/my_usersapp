require 'sinatra'
require_relative 'my_user_model.rb'

get '/' do
    @users=User.all()
    erb :index
end

get '/users' do
    status 200
    User.all.map{|col| col.slice("firstname", "lastname", "age", "email")}.to_json
end

post '/users' do
    if params[:firstname] != nil
        c_user = User.create(params)
        n_user = User.find(c_user.id)
        user={:firstname=>n_user.firstname,:lastname=>n_user.lastname,:age=>n_user.age,:password=>n_user.password,:email=>n_user.email}.to_json
    else
        ch_user=User.auth(params[:password],params[:email])
        if !ch_user[0].empty?
            status 200
            session[:user_id] = ch_user[0]["id"]
        else
            status 401
        end
        ch_user[0].to_json
    end
end

post '/sign_in' do
    vfy_user=User.auth(params[:password],params[:email])
    if !vfy_user.empty?
        status 200
        session[:user_id] = vfy_user[0]["id"]
    else
        status 401
    end
    vfy_user[0].to_json
end

put '/users' do
    User.update(session[:user_id], 'password', params[:password])
    user=User.find(session[:user_id])
    status 200
    user_info={:firstname=>user.firstname,:lastname=>user.lastname,:age=>user.age,:password=>user.password,:email=>user.email}.to_json
end

delete '/sign_out' do
    session[:user_id] = nil if session[:user_id]
    status 204
end


delete '/users' do
    status 204
end

set :bind, '0.0.0.0'
set :port, 8080
enable :sessions

