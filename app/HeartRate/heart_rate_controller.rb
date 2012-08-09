require 'rho/rhocontroller'
require 'helpers/browser_helper'

class HeartRateController < ParentController
  include BrowserHelper

  # GET /HeartRate
  def index
    @heartrates = HeartRate.find(:all)
    render :back => '/app'
  end

  # GET /HeartRate/{1}
  def show
    @heartrate = HeartRate.find(@params['id'])
    if @heartrate
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /HeartRate/new
  def new
    @heartrate = HeartRate.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /HeartRate/{1}/edit
  def edit
    @heartrate = HeartRate.find(@params['id'])
    if @heartrate
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /HeartRate/create
  def create
    @heartrate = HeartRate.create(@params['heartrate'])
    redirect :action => :index
  end

  # POST /HeartRate/{1}/update
  def update
    @heartrate = HeartRate.find(@params['id'])
    @heartrate.update_attributes(@params['heartrate']) if @heartrate
    redirect :action => :index
  end

  # POST /HeartRate/{1}/delete
  def delete
    @heartrate = HeartRate.find(@params['id'])
    @heartrate.destroy if @heartrate
    redirect :action => :index  
  end
end
