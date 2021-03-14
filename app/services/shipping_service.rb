require 'csv'
require 'date'
class ShippingService
  def initialize(params)
    @orderedItems = params[:orderedItems]
    @shippingRegion = params[:shippingRegion]
  end

  def read_csv
    @csvRows = []
    csv_text = File.read("initfiles.csv")
    csv = CSV.parse(csv_text, :headers => true, :quote_char => ",")
    csv.each do |row|
      csvRow = Array.new(4)
      csvRow[0] = row[0]
      csvRow[1] = row[1]
      # combine json from bad csv format
      json = row[2] + ',' + row[3] + ',' + row[4]
      csvRow[2] = JSON.parse(json[1..json.length-2])
      csvRow[3] = row[5]
      @csvRows << csvRow
    end
  end

  def filter_sort_csv_rows
    filteredRows = @csvRows.select { |el| el[2][@shippingRegion] != nil }
    if @orderedItems.any?
      filteredRows = filteredRows.select { |el| @orderedItems.any? { |s| el[0][s["itemName"]] } }
    end
    @sortedRows = filteredRows.sort_by! {|el| el[2][@shippingRegion]}
  end

  def fill_shipments
    shipments = []
    @orderedItems.each do |orderedItem|
      @sortedRows.each do |row|
        if (row[0].include? orderedItem['itemName']) && orderedItem["count"] > 0
          remainCount = Integer(orderedItem["count"]) - Integer(row[3])
          orderedItem["count"] = remainCount

          if remainCount > 0
            newShipment = [] << row[0] << row[1] << row[2][@shippingRegion] << orderedItem["count"]
            shipments << newShipment
          end
        end
      end
    end
    groupedBy = shipments.group_by { |s| s[1] }

    @resultShipments = []
    groupedBy.each do |item|
      items = []
      deliveryDateMax = nil
      item[1].each do |innerItem|
        items << {:title => innerItem[0], :count => innerItem[3]}
        plusDay = DateTime.now.advance(days: innerItem[2])
        if deliveryDateMax == nil || plusDay > deliveryDateMax
          deliveryDateMax = plusDay
        end
      end
      shipmentObj = { :supplier=>item[0], :delivery_date => deliveryDateMax, :items => items}
      @resultShipments << shipmentObj
    end
  end

  def search_shippings
    read_csv
    filter_sort_csv_rows
    fill_shipments

    # convert all dates to year-month-day format
    maxDate = (@resultShipments.max {|el| el[:delivery_date]})[:delivery_date].strftime("%Y-%m-%d")
    @resultShipments.each do |shipment|
      shipment[:delivery_date] = shipment[:delivery_date].strftime("%Y-%m-%d")
    end

    return { :shipments => @resultShipments, :delivery_date => maxDate }
  end
end
