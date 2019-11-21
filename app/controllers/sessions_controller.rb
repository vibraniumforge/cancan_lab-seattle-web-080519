class SessionsController

  def create
    if user_is_not_signed_in?
      return head(:unauthorized)
    else
      session[:user_id] = User.find_or_create_by(name: params[:name]).id
      redirect_to :back
    end
  end

  def destroy
    session.delete :user_id
    redirect to :back
end