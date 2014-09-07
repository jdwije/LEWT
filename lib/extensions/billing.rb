require "yaml"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.
#
# The Billing LEWT Extension handles processing invoices from extracted data and returns them as a hash
# for rendering.

class Billing < LewtExtension
  
  attr_reader :data
  
  # Sets up this extensions command
  def initialize
    super({:cmd => "invoice"})
  end
  
  # Processes the provided extract data into an invoice for the given targets.
  # options [Hash]:: An hash containing run-time options passed to this extension by LEWT.
  # data [LEWTBook]:: A hash-like object containing all the extracted data in the LEWTLedger format.
  # returns [Array]: The invoice data as an array of hashes.
  def process ( options, data )
    matchData = loadClientMatchData( options["target"] )
    bills = Array.new
    matchData.each do |client|
      bills.push( generateBill( client, data) )
    end
    return bills
  end

  # Generates a bill for the given client.
  # client [Hash]:: The client to calculate the invoice for.
  # data [LEWTBook]:: The data preloaded into the LEWTBook format.
  # returns [Hash]: The invoice data as a hash.  
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






