class Admin::SessionsController < AdminController
  skip_before_filter :require_login!
  
  def new
  end
end
