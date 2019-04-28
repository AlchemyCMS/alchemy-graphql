# frozen_string_literal: true

class DummyUser
  include ActiveModel::Model

  def alchemy_roles
    @alchemy_roles || %w(admin)
  end
end
