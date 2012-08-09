require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ParentController < Rho::RhoController   
    $connected_device_name = nil
    
    def logged_in?
        session = User.find(:first) 
        if session.nil?
            return false
        else
            return true
        end
    end

    def not_logged_in?
        session = User.find(:first) 
        if session.nil?
            return true
        else
            return false
        end
    end

    def token
        if logged_in?
            session = User.find(:first)
            return session.token
        end
    end

    def current_user
        if logged_in?
            user = User.find(:first, :conditions => { :token => token })
            return user
        end
    end

end