# frozen_string_literal: true

require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'
require 'alchemy/test_support/factories/element_factory'

RSpec.describe Alchemy::GraphQL::ElementFields do
  describe 'alchemyElements' do
    let!(:element) { create(:alchemy_element) }
    let!(:element_2) { create(:alchemy_element, name: 'header') }
    let!(:hidden_element) { create(:alchemy_element, public: false) }

    subject! do
      Alchemy::GraphQL::Schema.execute(query).to_h
    end

    context 'without any arguments' do
      let(:query) do
        %[{ elements: alchemyElements { name } }]
      end

      it 'returns all public elements' do
        is_expected.to eq({
          "data" => {
            "elements" => [{
              "name" => element.name
            }, {
              "name" => element_2.name
            }]
          }
        })
      end
    end

    context "with 'only' argument" do
      let(:query) do
        %[{ elements: alchemyElements(only: "article") { name } }]
      end

      it 'returns only these elements' do
        is_expected.to eq({
          "data" => {
            "elements" => [{
              "name" => element.name
            }]
          }
        })
      end
    end

    context "with 'except' argument" do
      let(:query) do
        %[{ elements: alchemyElements(except: "article") { name } }]
      end

      it 'returns all but these elements' do
        is_expected.to eq({
          "data" => {
            "elements" => [{
              "name" => element_2.name
            }]
          }
        })
      end
    end
  end
end
