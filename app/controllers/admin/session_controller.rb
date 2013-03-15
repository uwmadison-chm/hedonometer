class Admin::SessionController < AdminController
  skip_before_filter :require_login!

  def new
  end

  def destroy
    reset_session
    redirect_to admin_login_path
  end

  def create
    a = Admin.authenticate(params[:email], params[:password])
    if a
      dest = session.delete(:destination) || admin_root_url
      session[:admin_id] = a.id
      redirect_to dest
    else
      render action:'new'
    end
  end
end
