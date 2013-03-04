class AdminController < ApplicationController
  
  before_filter :require_login!
  
  def current_admin
    false
  end
  
  private
  def require_login!
    if !current_admin
      logger.debug "I AM REDIRECTING"
      redirect_to new_admin_session_path
    end
  end
  
end
