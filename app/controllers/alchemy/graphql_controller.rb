# frozen_string_literal: true

require 'alchemy/graphql/schema'

module Alchemy
  class GraphqlController < ApplicationController
    include Alchemy::ControllerActions
    include Alchemy::AbilityHelper

    def execute
      render json: Alchemy::GraphQL::Schema.execute(
        params[:query],
        variables: ensure_hash(params[:variables]),
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

    # Handle form data, JSON body, or a blank value
    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
    end
  end
end
