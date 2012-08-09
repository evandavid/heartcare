require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rho/rhobluetooth'

class ConnectionController < ParentController
  include BrowserHelper

  $device_name = nil
  $connected_device_name = nil
  $current_status = 'Not connected'
  $history = '---'
  $is_custom_connecting_in_progress = false
  $server_name = '' 
  $count = 0
  
  def index
    puts 'BluetoothChatController.index'
    $device_name = Rho::BluetoothManager.get_device_name()
    render
  end

  def on_connect_client
    puts 'BluetoothChatController.on_connect_client'
    if $connected_device_name == nil
       puts 'BluetoothChat::on_connect()'
       $current_status = 'Connecting ...'
       WebView.execute_js('setStatus("'+$current_status+'");')
       Rho::BluetoothManager.create_session(Rho::BluetoothManager::ROLE_CLIENT, url_for( :action => :create_session_callback) )
       if $is_blackberry
         #redirect :action => :index
         WebView.navigate( url_for :action => :index )
         ""
       end
    else
        on_disconnect
    end
  end

  def on_disconnect
    puts 'BluetoothChatController.on_disconnect'
    if $connected_device_name == nil
       Alert.show_popup "You are not connected now !"    
    else
       Rho::BluetoothSession.disconnect($connected_device_name)
       $connected_device_name = nil
       $current_status = 'Disconnected'
       WebView.execute_js('setStatus("'+$current_status+'");')
       WebView.execute_js('restoreButtonCaption();')
       WebView.execute_js('restoreCustomButtonCaption();')
       if $is_blackberry
         #redirect :action => :index
         WebView.navigate( url_for :action => :index )
         ""
       end
     end    
  end

  def create_session_callback
    $connected_device_name = @params['connected_device_name']
    if @params['status'] == Rho::BluetoothManager::OK
      $current_status = 'Connected to ['+$connected_device_name+']'
      if System::get_property('platform') == 'APPLE'  or   System::get_property('platform') == 'ANDROID'
          $server_name = $connected_device_name
          WebView.execute_js('setServerName("'+$server_name+'");') 
      end
      Rho::BluetoothSession.set_callback($connected_device_name, url_for(:action => :session_callback))
      if ($is_custom_connecting_in_progress)
             WebView.execute_js('setCustomButtonCaption("Disconnect");')
      else  
             WebView.execute_js('setButtonCaption("Disconnect");')
      end
    else 
       if @params['status'] == Rho::BluetoothManager::CANCEL
         $current_status = 'Cancelled by User'
       else
         $current_status = 'Error with Connection'
       end
    end
    WebView.execute_js('setStatus("'+$current_status+'");')
    if $is_blackberry
      #redirect :action => :index
      WebView.navigate( url_for :action => :index )
      ""
    end
    $is_custom_connecting_in_progress = false
  end

  def on_data_received
    puts 'BluetoothChat::on_data_received START'
    while Rho::BluetoothSession.get_status($connected_device_name) > 0
       message = Rho::BluetoothSession.read($connected_device_name)
       WebView.execute_js('hehe("'+message[11]+'");')
    end
    puts 'BluetoothChat::on_data_received FINISH'
    if $is_blackberry
      #redirect :action => :index
      WebView.navigate( url_for :action => :index )
      ""
    end
  end


  def session_callback
    puts 'BluetoothChat::on_data_received START'
    while Rho::BluetoothSession.get_status($connected_device_name) > 0 
       message = Rho::BluetoothSession.read($connected_device_name)
       unless message[11].nil? 
        if $count == 6
          speed = message[51]/256
          distance = message[49]/16
          WebView.execute_js('setAnimate("'+message[11].to_s+'");')
          WebView.execute_js('setHr("'+message[11].to_s+'");')
          WebView.execute_js('setDistance("'+distance.to_s+'");')
          WebView.execute_js('setSpeed("'+speed.to_s+'");')
          WebView.execute_js('setBattery("'+message[10].to_s+'");')
          $count = 0
          hr = HeartRate.create(
            :heart_rate => message[11],
            :beat => message[12],
            :battery => message[10],
            :stamp1 => message[13],
            :stamp2 => message[15],
            :stamp3 => message[17],
            :stamp4 => message[19],
            :stamp5 => message[21],
            :stamp6 => message[23],
            :stamp7 => message[25],
            :stamp8 => message[27],
            :stamp9 => message[29],
            :stamp10 => message[31],
            :stamp11 => message[33],
            :stamp12 => message[35],
            :stamp13 => message[37],
            :stamp14 => message[39],
            :stamp15 => message[41],
            :distance => message[49],
            :speed => message[51],
            :sync => 0
            )
        end
        $count = $count + 1
       end
    end
  end

  def on_close
    puts 'BluetoothChat::on_close()'
    Rho::BluetoothManager.off_bluetooth()
  end
end
