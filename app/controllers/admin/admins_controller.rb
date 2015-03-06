class Admin::AdminsController < AdminController
  before_action :require_can_change_admins!
  before_action :find_edit_admin, only: [:edit, :update]

  def index
    @new_admin = Admin.new
  end

  def create
    @new_admin = Admin.create create_params
    if @new_admin.new_record?
      render action: "index" and return
    end
    redirect_to admin_admins_path
  end

  def edit
  end

  def update
    if @edit_admin.update_attributes edit_params
      flash.notice = "Saved!"
      redirect_to edit_admin_admin_path(@edit_admin) and return
    end
    render action: "edit"
  end

  protected
  def require_can_change_admins!
    # require_admin_login! has already run so current_admin is not nil
    unless current_admin.can_change_admins?
      admin_logout!
    end
  end

  def find_edit_admin
    @edit_admin = Admin.find(params[:id])
  end

  def create_params
    params.require(:admin).permit(:email, :password)
  end

  def edit_params
    params.require(:admin).permit(:email, :password, :active, :can_change_admins)
  end
end
