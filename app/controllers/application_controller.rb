class ApplicationController < ActionController::Base
  protect_from_forgery

  layout ->(c) { c.request.xhr? ? false : "application" }

  include ApplicationHelper

  before_filter :set_locale

  private

  def set_locale
    if current_user && !current_user.locale.blank?
      I18n.locale = current_user.locale
    else
      # todo add locale determination by geo ip.
      I18n.locale = I18n.default_locale
    end
  end

  def signed_in_user_filter
    redirect_to root_url, notice: "Please sign in." unless current_user
  end

end
