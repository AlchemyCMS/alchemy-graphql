# frozen_string_literal: true

module Alchemy
  class GraphqlController < ApplicationController
    include Alchemy::ControllerActions
    include Alchemy::AbilityHelper

    def execute
      render json: Alchemy::GraphQL::Schema.execute(
        params[:query],
        context: {
          current_user: current_alchemy_user,
          current_ability: current_ability
        },
        operation_name: params[:operationName]
      )
    rescue StandardError => e
      raise e unless Rails.env.development?

      handle_error_in_development(e)
    end

    private

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
    end
  end
end
