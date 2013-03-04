class AdminController < ApplicationController
  
  before_filter :require_login!
  
  def current_admin
    Admin.where(id:session[:admin_id]).first
  end
  
  private
  def require_login!
    unless current_admin
      redirect_to new_admin_session_path
    end
  end
  
end
