class Admin::SessionController < AdminController
  skip_before_filter :require_login!
  
  def new
  end
  
  def destroy
    reset_session
    redirect_to admin_login_path
  end
end
