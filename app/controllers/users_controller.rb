class UsersController < ApplicationController

    get '/users/:slug' do
        if logged_in?
            @user = User.find_by_slug(params[:slug])
            @reviews = @user.reviews.sort { |a, b| b.created_at <=> a.created_at }
            erb :'users/show'
        else
            flash[:message] = "You do not have access to that page! Please log in or sign up below."
            redirect to '/'
        end
    end

    get '/welcome/:slug' do 
        @request
        if logged_in?
            @user = User.find_by_slug(params[:slug])
            @users = User.all
            if @user == current_user
                @reviews = @user.reviews.sort { |a, b| b.created_at <=> a.created_at }
                erb :'users/welcome'
            else
                redirect to "/users/#{@user.slug}"
            end
        else
            flash[:message] = "You do not have access to that page! Please log in or sign up below."
            redirect to '/'
        end
    end

    get '/signup' do
        if logged_in?
            @user = User.find_by_id(session[:user_id])
            flash[:message] = "You're already logged in!"
            redirect to "/welcome/#{@user.slug}"
        else
            erb :'users/signup'
        end
    end

    post '/signup' do
        if logged_in?
            @user = User.find_by_id(session[:user_id])
            flash[:message] = "You're already logged in!"
            redirect to "/welcome/#{@user.slug}"
        else
            if params[:username] == "" || params[:password] == "" || params[:email] == ""
                redirect to '/signup'
            else
                existing_user = User.find_by(username: params[:username])
                if existing_user
                    flash[:message] = "User already exists."
                    redirect to '/signup'
                else
                    @user = User.create(params)
                    session[:user_id] = @user.id
                    erb :'users/welcome'
                end
            end
        end
    end

    get '/login' do
        if logged_in?
            @user = User.find_by_id(session[:user_id])
            flash[:message] = "You're already logged in!"
            redirect to "/welcome/#{@user.slug}"
        else
            erb :'users/login'
        end
    end

    post '/login' do
        if logged_in?
            @user = User.find_by_id(session[:user_id])
            flash[:message] = "You're already logged in!"
            redirect to "/welcome/#{@user.slug}"
        else
            @user = User.find_by(username: params[:username])
            if @user && @user.authenticate(params[:password])
                session[:user_id] = @user.id
                redirect to "/welcome/#{@user.slug}"
            else
                flash[:message] = "Invalid username or password. Hint: they're case-sensitive!"
                redirect to '/login'
            end
        end
    end

    get '/logout' do 
        if logged_in?
            session.destroy
            redirect to "/"
        else
            flash[:message] = "You are not logged in!"
            redirect to '/'
        end
    end

end