require 'rho/rhocontroller'
require 'helpers/browser_helper'

class UserController < ParentController
  include BrowserHelper

  # GET /Session
  def index
    @sessions = User.find(:all)
    render :back => '/app'
  end

  # GET /Session/{1}
  def show
    @session = User.find(@params['id'])
    if @session
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Session/new
  def new
    @session = User.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Session/{1}/edit
  def edit
    @session = User.find(@params['id'])
    if @session
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Session/create
  def create
    @session = User.create(@params['session'])
    redirect :action => :index
  end

  # POST /Session/{1}/update
  def update
    @session = User.find(@params['id'])
    @session.update_attributes(@params['session']) if @session
    redirect :action => :index
  end

  # POST /Session/{1}/delete
  def delete
    @session = User.find(@params['id'])
    @session.destroy if @session
    redirect :action => :index  
  end
end
