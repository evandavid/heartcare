require 'parent_controller'
require 'helpers/browser_helper'
require 'rho/rhobluetooth'

class HomeController < ParentController
  include BrowserHelper

  # GET /Home
  def index
    if System.has_network
      if logged_in?
        msg = User.find(:first)
        puts "========================"
        puts msg.inspect
      else
         @msg = "Login First"
         WebView.navigate ( url_for :controller => :Settings, :action => :login, :query => {:msg => @msg} )
      end
    else
      WebView.navigate ( url_for :controller => :Settings, :action => :no_connection )
    end
  end

  # GET /Home/{1}
  def show
    render
  end

  def graph
    @hr = HeartRate.find(:all,:select => ['strtime','heart_rate']).map { |e| [e.strtime, e.heart_rate] }
    @ds = HeartRate.find(:all,:select => ['strtime','distance']).map { |e| [e.strtime, e.distance] }
    @sp = HeartRate.find(:all,:select => ['strtime','speed']).map { |e| [e.strtime, e.speed] }
    render
  end

  # GET /Home/new
  def new
    @home = Home.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Home/{1}/edit
  def edit
    @home = Home.find(@params['id'])
    if @home
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Home/create
  def create
    @home = Home.create(@params['home'])
    redirect :action => :index
  end

  # POST /Home/{1}/update
  def update
    @home = Home.find(@params['id'])
    @home.update_attributes(@params['home']) if @home
    redirect :action => :index
  end

  # POST /Home/{1}/delete
  def delete
    @home = Home.find(@params['id'])
    @home.destroy if @home
    redirect :action => :index  
  end
end
