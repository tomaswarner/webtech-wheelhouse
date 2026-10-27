class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      WelcomeMailer.welcome(@user).deliver_later
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Wheelhouse, #{@user.email_address}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # No role and no member of the staff: those are set from the seed or the console.
  def user_params
    params.expect(user: [:email_address, :password, :password_confirmation])
  end
end
