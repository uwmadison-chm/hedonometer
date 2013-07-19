class AdminController < ApplicationController

  before_action :require_login!

  def current_admin
    @current_admin ||= Admin.where(id:session[:admin_id]).first
  end

  def active_current_admin?
    current_admin and current_admin.active?
  end

  private
  def require_login!
    unless active_current_admin?
      reset_session
      session[:destination] = request.url
      redirect_to admin_login_path
    end
  end

end
