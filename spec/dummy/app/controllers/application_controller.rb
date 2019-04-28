# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protected

  def current_user
    @current_user ||= DummyUser.new
  end
end
