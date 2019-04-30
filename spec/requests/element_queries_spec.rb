require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'
require 'alchemy/test_support/factories/element_factory'

RSpec.describe 'Querying elements' do
  let(:element) { create(:alchemy_element) }

  shared_examples 'an element query' do
    it 'returns element' do
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('element')
      expect(json.dig('data', 'element', 'name')).to eq element.name
    end
  end

  describe 'by name' do
    context 'with exactMatch' do
      subject! do
        post '/graphql', params: {
          query: %[{ element: alchemyElement(name: "#{element.name}") { name } }]
        }
      end

      it_behaves_like 'an element query'
    end

    context 'without exactMatch' do
      let!(:element) do
        create(:alchemy_element, name: 'header')
      end

      subject! do
        post '/graphql', params: {
          query: %[{ element: alchemyElement(name: "head", exactMatch: false) { name } }]
        }
      end

      it_behaves_like 'an element query'
    end
  end

  describe 'contents' do
    let(:element) do
      create(:alchemy_element, name: 'header', autogenerate_contents: true).tap do |element|
        element.content_by_name(:greeting).essence.update(body: 'Hello World')
      end
    end

    before do
      allow_any_instance_of(Alchemy::EssencePicture).to receive(:picture_url) { '/foo/image/url' }
    end

    it 'can be included' do
      post '/graphql', params: {
        query: %[{
          element: alchemyElement(name: "#{element.name}") {
            contents {
              ingredient
            }
          }
        }]
      }
      json = JSON.parse(response.body)
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

    describe 'can be filtered' do
      it 'by only' do
        post '/graphql', params: {
          query: %[{
            element: alchemyElement(name: "#{element.name}") {
              contents(only: "greeting") {
                ingredient
              }
            }
          }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'contents')).to match_array([
          {
            "ingredient" => "Hello World"
          }
        ])
      end

      it 'by except' do
        post '/graphql', params: {
          query: %[{
            element: alchemyElement(name: "#{element.name}") {
              contents(except: "greeting") {
                ingredient
              }
            }
          }]
        }
        json = JSON.parse(response.body)
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
    subject! do
      post '/graphql', params: {
        query: %[{ element: alchemyElement(id: "#{element.id}") { name } }]
      }
    end

    it_behaves_like 'an element query'
  end
end
