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

  test "Scenario2_one_supplier_faster_than_other_should_be_3_days" do
    @params = {
      :shippingRegion => "us",
      :orderedItems => [
        {
          'itemName' => "pink_t-shirt",
          'count' => 2
        }
      ]}
    shippings = ShippingService.new(@params, 'testDb.csv').search_shippings
    dateNow = DateTime.now.strftime("%Y-%m-%d")

    days_between = (Date.parse(shippings[:delivery_date]) - Date.parse(dateNow)).to_i
    assert days_between === 3
  end

  test "Scenario4_full_max_basket_from_one_supplier" do
    @params = {
      :shippingRegion => "us",
      :orderedItems => [
        {
    #first Shirts4U with 3 mugs
    #second Shirts Unlimited with 2 mugs
          'itemName' => "black_mug",
          'count' => 5
        }
      ]}
    shippings = ShippingService.new(@params, 'testDb.csv').search_shippings
    assert shippings[:shipments][0][:supplier] === 'Shirts4U'
    assert shippings[:shipments][0][:items][0][:count] === 3
    assert shippings[:shipments][1][:supplier] === 'Shirts Unlimited'
    assert shippings[:shipments][1][:items][0][:count] === 2
  end
  end