require 'swagger_helper'

RSpec.describe 'api/shipping', type: :request do

  path '/api/shipping/search' do

    post('search shipping') do
      response(200, 'successful') do
        tags 'Shippings'
        consumes 'application/json'
        parameter name: :json, in: :body, schema: {
          type: :object,
          properties: {
            shippingRegion: { type: :string },
            orderedItems: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  itemName: { type: :string },
                  count: { type: :integer },
                }},

            }
          }
        }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
