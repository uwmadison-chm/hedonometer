class Admin::SessionController < AdminController
  skip_before_filter :require_login!
  before_filter :reset_session
  
  def new
  end
end
