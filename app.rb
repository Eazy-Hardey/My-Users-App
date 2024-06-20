require 'json'
require 'sinatra'
require './my_user_model.rb'

set('views', './views')

set :bind, '0.0.0.0'
set :port, 8080

enable :sessions


get '/users' do
    status 200
    User.all.map{|user| user.slice("firstname", "lastname", "age", "email")}.to_json
    # users added to the database
end

post '/sign_in' do
    confirmUser = User.authentication(params[:password], params[:email])
    if !confirmUser.empty?
        status 200
        session[:user_id] = confirmUser[0]["id"]
        "Signed in"
    else
        status 401
        "Not authorized"
    end
    confirmUser[0].to_json
end

post '/users' do
    if params[:firstname] != nil
        makeUser = User.create(params)
        freshUser = User.find(makeUser.id)
        userData = {:firstname=>freshUser.firstname, :lastname=>freshUser.lastname, :age=>freshUser.age, :email=>freshUser.email}.to_json
        # "A user has been added to the database"
    else
        inspectUser = User.authentication(params[:password], params[:email])
        if !inspectUser[0].empty?
            status 200
            session[:user_id] = inspectUser[0]["id"]
            # "Signed in"
        else
            status 401
            "Not authorized"
        end
        inspectUser[0].to_json
    end
end

put '/users' do
    User.update(session[:user_id], 'password', params[:password])
    updatedUser = User.find(session[:user_id])
    status 200
    userData = {:firstname=>updatedUser.firstname, :lastname=>updatedUser.lastname, :age=>updatedUser.age, :email=>updatedUser.email}.to_json
end

delete '/sign_out' do
    if session[:user_id]
        session[:user_id] = nil
        status 204
        # "Signed out"
    end
end

# gandalf couln't permit deleting a user from the db
delete '/users' do
    if !session[:user_id].empty?
        User.destroy(session[:user_id])
        status 204
        # "User deleted"
    end
end

get '/' do
    @users = User.all
    erb :index
 end