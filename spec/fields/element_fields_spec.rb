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

  describe 'alchemyElement' do
    let(:element) { create(:alchemy_element) }

    subject(:json) do
      Alchemy::GraphQL::Schema.execute(query).to_h
    end

    shared_examples 'an element query' do
      it 'returns element' do
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'name')).to eq element.name
      end
    end

    describe 'by name' do
      context 'with exactMatch' do
        let(:query) do
          %[{ element: alchemyElement(name: "#{element.name}") { name } }]
        end

        it_behaves_like 'an element query'
      end

      context 'without exactMatch' do
        let!(:element) do
          create(:alchemy_element, name: 'header')
        end

        let(:query) do
          %[{ element: alchemyElement(name: "head", exactMatch: false) { name } }]
        end

        it_behaves_like 'an element query'
      end
    end

    describe 'requesting contents' do
      let(:element) do
        create(:alchemy_element, name: 'header', autogenerate_contents: true).tap do |element|
          element.content_by_name(:greeting).essence.update(body: 'Hello World')
        end
      end

      before do
        allow_any_instance_of(Alchemy::EssencePicture).to receive(:picture_url) { '/foo/image/url' }
      end

      context 'without any arguments' do
        let(:query) do
          %[{
            element: alchemyElement(name: "#{element.name}") {
              contents {
                ingredient
              }
            }
          }]
        end

        it 'returns all contents' do
          expect(json).to have_key('data')
          expect(json['data']).to have_key('element')
          expect(json.dig('data', 'element', 'contents')).to match_array([
            {
              "ingredient" => "Hello World"
            },
            {
              "ingredient" => "/foo/image/url"
            }
          ])
        end
      end

      describe "with 'only' argument" do
        let(:query) do
          %[{
            element: alchemyElement(name: "#{element.name}") {
              contents(only: "greeting") {
                ingredient
              }
            }
          }]
        end

        it 'only includes these contents' do
          expect(json).to have_key('data')
          expect(json['data']).to have_key('element')
          expect(json.dig('data', 'element', 'contents')).to match_array([
            {
              "ingredient" => "Hello World"
            }
          ])
        end
      end

      context "with 'except' argument" do
        let(:query) do
          %[{
            element: alchemyElement(name: "#{element.name}") {
              contents(except: "greeting") {
                ingredient
              }
            }
          }]
        end

        it 'returns all but these contents' do
          expect(json).to have_key('data')
          expect(json['data']).to have_key('element')
          expect(json.dig('data', 'element', 'contents')).to match_array([
            {
              "ingredient" => "/foo/image/url"
            }
          ])
        end
      end
    end

    describe 'by id' do
      let(:query) do
        %[{ element: alchemyElement(id: "#{element.id}") { name } }]
      end

      it_behaves_like 'an element query'
    end
  end
end
