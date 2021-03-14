require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  test "Scenario1_the_most_delivery_time_should_be_6_days" do
    @params = {
      :shippingRegion => "us",
      :orderedItems => [
                        {
                          'itemName' => "black_mug",
                          'count' => 1
                        },
                        {
                          'itemName' => "blue_t-shirt",
                          'count' => 1
                        }
                      ]}
    shippings = ShippingService.new(@params, 'testDb.csv').search_shippings
    dateNow = DateTime.now.strftime("%Y-%m-%d")

    days_between = (Date.parse(shippings[:delivery_date]) - Date.parse(dateNow)).to_i
    assert days_between === 6
  end
  end