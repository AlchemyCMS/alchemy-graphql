require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'
require 'alchemy/test_support/factories/element_factory'

RSpec.describe ':post /graphql' do
  describe 'PageFields' do
    let(:page) { create(:alchemy_page, :public) }

    context 'using alchemyPageByName' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageByName(name: "#{page.name}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end

      describe 'elements can be filtered' do
        let(:page) do
          create(:alchemy_page, autogenerate_elements: true)
        end

        it 'by only' do
          post '/graphql', params: {
            query: %[{
              page: alchemyPageByName(name: "#{page.name}") {
                elements(only: "article") {
                  name
                }
              }
            }]
          }
          json = JSON.parse(response.body)
          expect(json).to have_key('data')
          expect(json['data']).to have_key('page')
          expect(json.dig('data', 'page', 'elements')).to match_array([
            {
              "name" => "article"
            }
          ])
        end

        it 'by except' do
          post '/graphql', params: {
            query: %[{
              page: alchemyPageByName(name: "#{page.name}") {
                elements(except: "article") {
                  name
                }
              }
            }]
          }
          json = JSON.parse(response.body)
          expect(json).to have_key('data')
          expect(json['data']).to have_key('page')
          expect(json.dig('data', 'page', 'elements')).to match_array([
            {
              "name" => "header"
            }
          ])
        end
      end
    end

    context 'using alchemyPageById' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageById(id: "#{page.id}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end

    context 'using alchemyPageByUrl' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageByUrl(url: "#{page.urlname}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end
  end

  describe 'ElementFields' do
    let(:element) { create(:alchemy_element) }

    context 'using alchemyElementByName' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ element: alchemyElementByName(name: "#{element.name}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'name')).to eq element.name
      end
    end

    describe 'contents can be filtered' do
      let(:element) do
        create(:alchemy_element, name: 'header', autogenerate_contents: true).tap do |element|
          element.content_by_name(:greeting).essence.update(body: 'Hello World')
        end
      end

      it 'by only' do
        post '/graphql', params: {
          query: %[{
            element: alchemyElementByName(name: "#{element.name}") {
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
        allow_any_instance_of(Alchemy::EssencePicture).to receive(:picture_url) { '/foo/image/url' }
        post '/graphql', params: {
          query: %[{
            element: alchemyElementByName(name: "#{element.name}") {
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

    context 'using alchemyElementById' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ element: alchemyElementById(id: "#{element.id}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'name')).to eq element.name
      end
    end
  end
end
