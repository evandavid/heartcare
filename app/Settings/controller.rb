require 'rho'
require 'parent_controller'
require 'rho/rhoerror'
require 'Member/member'
require 'helpers/browser_helper'
require 'json'

class SettingsController < ParentController
  include BrowserHelper
  
  def index
    if System.has_network
      @msg = @params['msg']
      render
    elsif not_logged_in?
      WebView.navigate ( url_for :controller => :Settings, :action => :login )
    else
      WebView.navigate ( url_for :controller => :Settings, :action => :no_connection )
    end
  end
  
  def signup
    @msg = Rho::RhoSupport.url_decode(@params['msg'])
    render 
  end

  def update
    @msg = Rho::RhoSupport.url_decode(@params['msg'])
    @user = User.find(:first, :conditions => { :token => token })
    render
  end

  def update_password
    @msg = Rho::RhoSupport.url_decode(@params['msg'])
    render
  end

  def profile
    @msg =@params['msg']
    @user = User.find(:first, :conditions => { :token => token })
    render
  end

  def do_update
    if @params['first_name'] and @params['last_name'] and @params['address'] and @params['mobile'] and @params['email']
      begin
        body = '{ "token" : "'+token+'", "email" : "'+@params['email']+'","mobile" : "'+@params['mobile']+'","first_name" : "'+@params['first_name']+'","last_name" : "'+@params['last_name']+'", "address" : "'+@params['address']+'" }'
        Rho::AsyncHttp.post( 
                      :url => Rho::RhoConfig.server_url+'api/v1/user/update.json', 
                      :headers => {'Content-type'=>'application/json'}, 
                      :body => body,
                      :callback => url_for(:action => :update_callback))
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = @params['password']
        render :action => :update
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :update
    end
  end

  def do_update_password
    if @params['password'] 
      begin
        body = '{ "token" : "'+token+'", "password" : "'+@params['password']+'" }'
        Rho::AsyncHttp.post( 
                      :url => Rho::RhoConfig.server_url+'api/v1/user/update_password.json', 
                      :headers => {'Content-type'=>'application/json'}, 
                      :body => body,
                      :callback => url_for(:action => :update_password_callback))
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = @params['password']
        render :action => :update_password
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :update_password
    end
  end
  
  def do_signup
    if @params['login'] and @params['password'] and @params['email']
      begin
        body = '{"password" : "'+@params['password']+'","username" : "'+@params['login']+'", "email" : "'+@params['email']+'" }'
        Rho::AsyncHttp.post( 
                      :url => Rho::RhoConfig.server_url+'api/v1/users.json', 
                      :headers => {'Content-type'=>'application/json'}, 
                      :body => body,
                      :callback => url_for(:action => :signup_callback))
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = @params['password']
        render :action => :signup
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :signup
    end
  end
  
  def signup_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      WebView.navigate Rho::RhoConfig.start_path
    else
      msgs = Rho::JSON.parse(@params['body']) 
      puts "==========================="
      @msg = msgs['message']
        puts "========="
        puts @msg
      WebView.navigate ( url_for :action => :signup, :query => {:msg => "#{@msg}"} )
    end
  end

  def update_password_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      WebView.navigate ( url_for :action => :profile, :query => {:msg => "Update Profile Success"} )
    else
      msgs = Rho::JSON.parse(@params['body']) 
      @msg = msgs['message']
      WebView.navigate ( url_for :action => :update_password, :query => {:msg => "#{@msg}"} )
    end
  end

  def update_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      user = User.find(:first , :conditions => { :token => token })
      u = @params['body']['user']
      user.update_attributes( :token => @params['body']['token'], :username => u['username'], :email => u['email'], :password => "", :first_name => u['first_name'], :address => u['address'], :last_name => u['last_name'], :mobile => u['mobile'] )
      WebView.navigate ( url_for :action => :profile, :query => {:msg => "Update Profile Success"} )
    else
      msgs = Rho::JSON.parse(@params['body']) 
      @msg = msgs['message']
      WebView.navigate ( url_for :action => :update, :query => {:msg => "#{@msg}"} )
    end
  end

  def login
    ses = User.find(:all)
    ses.each do |p|
      p.destroy
    end
    @msg = @params['msg']
    render :action => :login
  end
  
  def no_connection
    render
  end

  def login_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      u = @params['body']['user']
      User.create( :token => @params['body']['token'], :username => u['username'], :email => u['email'], :password => "", :first_name => u['first_name'], :address => u['address'], :last_name => u['last_name'], :mobile => u['mobile'] )
      WebView.navigate Rho::RhoConfig.start_path
    else
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      end
        
      if !@msg || @msg.length == 0  
        msg = Rho::JSON.parse(@params['body']) 
        @msg = msg['message']
      end
      
      WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    end  
  end

  def do_login
    if @params['login'] and @params['password']
      begin
        body = '{"password" : "'+@params['password']+'","username" :"'+@params['login']+'"}'
        Rho::AsyncHttp.post( 
                      :url => Rho::RhoConfig.server_url+'api/v1/tokens.json', 
                      :headers => {'Content-type'=>'application/json'}, 
                      :body => body,
                      :callback => url_for(:action => :login_callback))
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = @params['password']
        render :action => :login
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :login
    end
  end
  
  def logout
    Rho::AsyncHttp.post( :url => Rho::RhoConfig.server_url+'api/v1/tokens/'+token+'.json', 
                         :headers => {'Content-type'=>'application/json'}, 
                         :http_command => "DELETE")
    users = User.find(:all)
    users.each do |u|
      u.destroy
    end
    @msg = " You have been logged out."
    Rhom::Rhom.database_local_reset
    WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
#    SyncEngine.dosync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
#    SyncEngine.dosync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def sync_notify
  	status = @params['status'] ? @params['status'] : ""
  	
  	# un-comment to show a debug status pop-up
  	#Alert.show_status( "Status", "#{@params['source_name']} : #{status}", Rho::RhoMessages.get_message('hide'))
  	
  	if status == "in_progress" 	
  	  # do nothing
  	elsif status == "complete"
      WebView.navigate Rho::RhoConfig.start_path if @params['sync_type'] != 'bulk'
  	elsif status == "error"
	
      if @params['server_errors'] && @params['server_errors']['create-error']
        SyncEngine.on_sync_create_error( 
          @params['source_name'], @params['server_errors']['create-error'].keys, :delete )
      end

      if @params['server_errors'] && @params['server_errors']['update-error']
        SyncEngine.on_sync_update_error(
          @params['source_name'], @params['server_errors']['update-error'], :retry )
      end
      
      err_code = @params['error_code'].to_i
      rho_error = Rho::RhoError.new(err_code)
      
      @msg = @params['error_message'] if err_code == Rho::RhoError::ERR_CUSTOMSYNCSERVER
      @msg = rho_error.message unless @msg && @msg.length > 0   

      if rho_error.unknown_client?( @params['error_message'] )
        Rhom::Rhom.database_client_reset
        SyncEngine.dosync
      elsif err_code == Rho::RhoError::ERR_UNATHORIZED
        WebView.navigate( 
          url_for :action => :login, 
          :query => {:msg => "Server credentials are expired"} )                
      elsif err_code != Rho::RhoError::ERR_CUSTOMSYNCSERVER
        WebView.navigate( url_for :action => :err_sync, :query => { :msg => @msg } )
      end    
	end
  end  
end
