require 'csv'
require 'date'

class ShippingService
  def initialize(params, csvPath = "db.csv")
    @orderedItems = params[:orderedItems]
    @shippingRegion = params[:shippingRegion]
    @csvPath = csvPath
  end

  def read_csv
    @csvRows = []
    csv_text = File.read(@csvPath)
    csv = CSV.parse(csv_text, :headers => true, :quote_char => ",")
    csv.each do |row|
      csvRow = Array.new(4)
      csvRow[0] = row[0] # product_name
      csvRow[1] = row[1] # supplier
      # combine json from bad csv format
      json = row[2] + ',' + row[3] + ',' + row[4]
      csvRow[2] = JSON.parse(json[1..json.length - 2]) # delivery_times
      csvRow[3] = row[5] # in_stock
      @csvRows << csvRow
    end
  end

  def filter_sort_csv_rows
    filteredRows = @csvRows.select { |el| el[2][@shippingRegion] }
    if @orderedItems.any?
      filteredRows = filteredRows.select { |el| @orderedItems.any? { |s| el[0][s["itemName"]] } }
    end
    @sortedRows = filteredRows.sort_by! { |el| el[2][@shippingRegion] }
  end

  def continue_while_needed_supplier_not_be_found shipments, currentSupplier, orderedItem
    if shipments.any?
      shipments.each do |el|
        allSupls = @csvRows.select { |row| el[1] != currentSupplier && row[1] === el[1] && row[0] === orderedItem && Integer(row[3]) > 0}

        return allSupls.any?
      end
    end

    return false
  end

  def fill_shipments
    shipments = []
    @orderedItems.each do |orderedItem|
      @sortedRows.each do |row|
        if (row[0].include? orderedItem['itemName']) && orderedItem["count"] > 0
          if continue_while_needed_supplier_not_be_found shipments, row[1], orderedItem['itemName']
            next
          end

          remainCount = Integer(row[3]) - Integer(orderedItem["count"])

          gotItems = remainCount < 0 ? Integer(row[3]) : Integer(orderedItem["count"])
          row[3] = remainCount <= 0 ? 0 : row[3]
          orderedItem["count"] = orderedItem["count"] - gotItems # instead this action we can check shipments array
          newShipment = [] << row[0] << row[1] << row[2][@shippingRegion] << gotItems
          shipments << newShipment
        end
      end
    end
    groupedBy = shipments.group_by { |s| s[1] }

    @resultShipments = []
    groupedBy.each do |item|
      items = []
      deliveryDateMax = nil
      item[1].each do |innerItem|
        items << { :title => innerItem[0], :count => innerItem[3] }
        plusDay = DateTime.now.advance(days: innerItem[2])
        if deliveryDateMax == nil || plusDay > deliveryDateMax
          deliveryDateMax = plusDay
        end
      end
      @resultShipments << { :supplier => item[0], :delivery_date => deliveryDateMax, :items => items }
    end
  end

  def search_shippings
    read_csv
    filter_sort_csv_rows
    fill_shipments

    if @resultShipments.any?
      # convert all dates to year-month-day format
      maxDate = (@resultShipments.max_by { |el| el[:delivery_date] })[:delivery_date].strftime("%Y-%m-%d")
      @resultShipments.each do |shipment|
        shipment[:delivery_date] = shipment[:delivery_date].strftime("%Y-%m-%d")
      end

      return { :shipments => @resultShipments, :delivery_date => maxDate }
    else
      return { :shipments => [], :delivery_date => nil }
    end
  end
end
