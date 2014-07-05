#!/usr/bin/env ruby

# @class: ClientInvoicing 
#
# Takes an array of EventDataStructure objects and processes them into an invoice for the
# 'recipientClient' which you can configure in ./config/clients.yaml. The resulting invoice
# is structured YAML, it can be converted and prettified to MARKDOWN.
require "yaml"

# load File.expand_path('../render-invoice.rb', __FILE__)

class Billing < LewtExtension
  
  attr_reader :data

  def initialize
    super
    register_extension "simple_billing"
  end
  
  # handles the invoicing workflow for you!
  def process( options, data )
    @data = data
    @customer = getClient( options["target"] )
    bill = generateBill(@customer)
    return bill
  end

  def getClient( query ) 
    client = nil
    customers.each do |c|
      buildQ = [ c["name"], c["alias"] ].join("|")
      regex = Regexp.new(buildQ, Regexp::IGNORECASE)
      if regex.match( query ) != nil
        client = c
      end
    end
    return client
  end

  def loadClientMatchData( query )
    requestedClients = Array.new
    if query == nil
      customers.each do |client|
        requestedClients.push(client["name"])
        requestedClients.push(client["alias"])
      end
    else
      requestedClients = Array.new
      customers.each do |client|
        query.split(",").each do |q|
          if [client["alias"], client["name"]].include?(q) == true 
            requestedClients.push(client["name"])
            requestedClients.push(client["alias"])
          end
        end
      end
    end
    return requestedClients
  end

  def generateBill(client)
    bill = {
      "date_created" => DateTime.now.strftime("%d/%m/%y"),
#      "date_begin"=> @events.dateBegin.strftime("%d/%m/%y"),
 #     "date_end"=> @events.dateEnd.strftime("%d/%m/%y"),
      "billed_to" => client,
      "billed_from" => enterprise,
      "items" => [
                  # eg: { description, duration, rate, total
                 ],
      "sub-total" => 0,
      "tax" => nil,
      "total" => nil
    }    
    # loop events and filter for requested matched
    @data.each do |e|
      item = {
        "description" => e.description.to_s,
        "duration" => e.duration,
        "rate" => client["rate"],
        "total" => e.duration * client["rate"],
        "start" => e.start.strftime("%d/%m/%y %l:%M%P"),
        "end" => e.end.strftime("%d/%m/%y %l:%M%P")
      }
      bill["items"].push( item );
      bill["sub-total"] += item["total"]
    end     
    bill["tax"] = bill["sub-total"] * enterprise["invoice-tax"]
    bill["total"] = bill["sub-total"] + bill["tax"]
    
    return bill;
  end

end






