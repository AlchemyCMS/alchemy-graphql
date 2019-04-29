require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe 'Querying pages' do
  let(:page) { create(:alchemy_page, :public) }

  describe 'using alchemyPageByName' do
    context 'with exactMatch' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageByName(name: "#{page.name}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end

    context 'without exactMatch' do
      let!(:page) do
        create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
      end

      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageByName(name: "Contact", exactMatch: false) { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end

    describe 'elements' do
      let(:page) do
        create(:alchemy_page, autogenerate_elements: true)
      end

      it 'can be included' do
        post '/graphql', params: {
          query: %[{
            page: alchemyPageByName(name: "#{page.name}") {
              elements {
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
          },
          {
            "name" => "article"
          }
        ])
      end

      describe 'can be filtered' do
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
  end

  describe 'using alchemyPageById' do
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

  describe 'using alchemyPageByUrl' do
    describe 'with exactMatch' do
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

    describe 'without exactMatch' do
      let!(:page) do
        create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
      end

      it 'works' do
        post '/graphql', params: {
          query: %[{ page: alchemyPageByUrl(url: "contact", exactMatch: false) { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end
  end
end
