#!/usr/bin/env ruby

require "yaml"


class Billing < LewtExtension
  
  attr_reader :data

  def initialize
    super({:cmd => "invoice"})
  end
  
  # handles the invoicing workflow for you!
  def process ( options, data )
    matchData = loadClientMatchData( options["target"] )
    bills = Array.new
    matchData.each do |client|
      bills.push( generateBill( client, data) )
    end
    return bills
  end

  def generateBill(client, data)
    bill = {
      "date_created" => DateTime.now.strftime("%d/%m/%y"),
      # "date_begin"=> @events.dateBegin.strftime("%d/%m/%y"),
      # "date_end"=> @events.dateEnd.strftime("%d/%m/%y"),
      "billed_to" => client,
      "billed_from" => enterprise,
      "items" => [
                  # eg: { description, duration, rate, total
                 ],
      "sub-total" => 0,
      "tax" => nil,
      "total" => nil
    }    
    # loop events and filter for requested entity (client)
    data.each do |row|
      if row["entity"] == client["name"]
        item = {
          "description" => row["description"],
          "duration" => row["quantity"],
          "rate" => row["unit_cost"],
          "total" => row["total"],
          "start" => row["date_start"].strftime("%d/%m/%y %l:%M%P"),
          "end" => row["date_end"].strftime("%d/%m/%y %l:%M%P")
        }
        bill["items"].push( item );
        bill["sub-total"] += item["total"]
      end

    end     
    bill["tax"] = bill["sub-total"] * enterprise["invoice-tax"]
    bill["total"] = bill["sub-total"] + bill["tax"]
    
    return bill;
  end

end






