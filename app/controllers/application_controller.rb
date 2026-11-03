class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  # Every action must ask a policy: index through policy_scope, every other
  # action through authorize. If an action forgets, Pundit raises
  # AuthorizationNotPerformedError / PolicyScopingNotPerformedError, so the
  # mistake shows up in development (and in tests). Controllers added later
  # inherit this check without doing anything.
  #
  # One method instead of `after_action :verify_authorized, except: :index`
  # plus `after_action :verify_policy_scoped, only: :index`: with Rails'
  # raise_on_missing_callback_actions, an `only: :index` callback raises in
  # controllers that have no index action (sessions, intake photos...).
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Pundit asks for current_user; the Rails 8 generator has Current.user.
  # On public actions (services index/show) require_authentication is skipped,
  # so the session is resumed here first: a signed-in owner on the price list
  # still sees the Edit buttons the policy allows them.
  def pundit_user
    resume_session
    Current.user
  end

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  # A refusal is a 403 with a page in the app's layout, never a 500 or a
  # redirect. authorize runs before any write, so a refused update/destroy
  # changes nothing. Visitors never get here: require_authentication runs
  # first and sends them to sign in.
  def user_not_authorized
    render "shared/forbidden", status: :forbidden
  end
end
