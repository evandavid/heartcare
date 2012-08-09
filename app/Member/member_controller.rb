require 'rho/rhocontroller'
require 'helpers/browser_helper'

class MemberController < Rho::RhoController
  include BrowserHelper

  # GET /User
  def index
    @users = Member.find(:all)
    render :back => '/app'
  end

  # GET /User/{1}
  def show
    @user = Member.find(@params['id'])
    if @user
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /User/new
  def new
    @user = Member.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /User/{1}/edit
  def edit
    @user = Member.find(@params['id'])
    if @user
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /User/create
  def create
    @user = Member.create(@params['user'])
    redirect :action => :index
  end

  # POST /User/{1}/update
  def update
    @user = Member.find(@params['id'])
    @Member.update_attributes(@params['user']) if @user
    redirect :action => :index
  end

  # POST /User/{1}/delete
  def delete
    @user = Member.find(@params['id'])
    @Member.destroy if @user
    redirect :action => :index  
  end
end
