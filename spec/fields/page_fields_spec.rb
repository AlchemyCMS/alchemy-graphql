# frozen_string_literal: true

require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe Alchemy::GraphQL::PageFields do
  describe 'alchemyPage' do
    let(:page) { create(:alchemy_page, :public) }

    subject(:json) do
      Alchemy::GraphQL::Schema.execute(query).to_h
    end

    shared_examples 'a page query' do
      it 'returns page' do
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end

    describe 'by name' do
      context 'with exactMatch' do
        let(:query) do
          %[{ page: alchemyPage(name: "#{page.name}") { name } }]
        end

        it_behaves_like 'a page query'
      end

      context 'without exactMatch' do
        let!(:page) do
          create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
        end

        let(:query) do
          %[{ page: alchemyPage(name: "Contact", exactMatch: false) { name } }]
        end

        it_behaves_like 'a page query'
      end

      context 'and by page_layout' do
        let(:query) do
          %[{
            page: alchemyPage(
              pageLayout: "#{page.page_layout}"
              name: "#{page.name}"
            ) { name }
          }]
        end

        it_behaves_like 'a page query'
      end

      describe 'requesting elements' do
        let(:page) do
          create(:alchemy_page, autogenerate_elements: true)
        end

        context 'without any arguments' do
          let(:query) do
            %[{
              page: alchemyPage(name: "#{page.name}") {
                elements {
                  name
                }
              }
            }]
          end

          it 'returns all elements' do
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
        end

        context "with 'only' argument" do
          let(:query) do
            %[{
              page: alchemyPage(name: "#{page.name}") {
                elements(only: "article") {
                  name
                }
              }
            }]
          end

          it 'includes only these elements' do
            expect(json).to have_key('data')
            expect(json['data']).to have_key('page')
            expect(json.dig('data', 'page', 'elements')).to match_array([
              {
                "name" => "article"
              }
            ])
          end
        end

        context "with 'except' argument" do
          let(:query) do
            %[{
              page: alchemyPage(name: "#{page.name}") {
                elements(except: "article") {
                  name
                }
              }
            }]
          end

          it 'returns all but these elements' do
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

    describe 'by id' do
      let(:query) do
        %[{ page: alchemyPage(id: "#{page.id}") { name } }]
      end

      it_behaves_like 'a page query'
    end

    describe 'by urlname' do
      context 'with exactMatch' do
        let(:query) do
          %[{ page: alchemyPage(urlname: "#{page.urlname}") { name } }]
        end

        it_behaves_like 'a page query'
      end

      context 'without exactMatch' do
        let!(:page) do
          create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
        end

        let(:query) do
          %[{ page: alchemyPage(urlname: "contact", exactMatch: false) { name } }]
        end

        it_behaves_like 'a page query'
      end
    end

    describe 'by page_layout' do
      context 'with exactMatch' do
        let(:query) do
          %[{ page: alchemyPage(pageLayout: "#{page.page_layout}") { name } }]
        end

        it_behaves_like 'a page query'
      end

      context 'without exactMatch' do
        let!(:page) do
          create(:alchemy_page, page_layout: 'standard')
        end

        let(:query) do
          %[{ page: alchemyPage(pageLayout: "stand", exactMatch: false) { name } }]
        end

        it_behaves_like 'a page query'
      end
    end
  end
end
