# -*- encoding : utf-8 -*-

class AdminController < ApplicationController
  layout 'admin'

  before_action :require_admin_login!

  def current_admin
    @current_admin ||= Admin.where(id:session[:admin_id]).first
  end
  helper_method :current_admin

  def logged_in?
    active_current_admin?
  end
  helper_method :logged_in?

  def active_current_admin?
    current_admin and current_admin.active?
  end

  def current_survey
    @current_survey ||= current_admin.surveys.find(params[:survey_id])
  end
  helper_method :current_survey

  private
  def require_admin_login!
    unless active_current_admin?
      admin_logout!
    end
  end

  def admin_logout!
    logger.debug("Forcing logout.")
    reset_session
    session[:destination] = request.url
    redirect_to admin_login_path
  end
end
