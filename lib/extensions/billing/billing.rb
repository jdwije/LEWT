#!/usr/bin/env ruby

# @class: ClientInvoicing 
#
# Takes an array of EventDataStructure objects and processes them into an invoice for the
# 'recipientClient' which you can configure in ./config/clients.yaml. The resulting invoice
# is structured YAML, it can be converted and prettified to MARKDOWN.
require "yaml"

# load File.expand_path('../render-invoice.rb', __FILE__)

class Billing
  
  def initialize
    @clients = YAML.load_file(File.expand_path('../../../config/clients.yaml', __FILE__))
    @company = YAML.load_file(File.expand_path('../../../config/company.yaml', __FILE__))
  end

  def self.registerHandlers
    return {
      "process" => method(:doInvoicing),
      "initialize" => method(:setOptions)
    }
  end
  
  def self.setOptions(args, opts, defaults)
    opts.on("-t", "--target [STRING]", String, "Execute on target client") do |t|
      defaults["target"] = t
    end
    response = {
      "options" => opts,
      "defaults" => defaults
    }
    return response
  end

  # handles the invoicing workflow for you!
  def self.doInvoicing( args, events, options )
    command = ARGV[0]
    target = options["target"]
    @clients = YAML.load_file( File.expand_path('../../../config/clients.yaml', __FILE__) )
    @company = YAML.load_file( File.expand_path('../../../config/company.yaml', __FILE__) )
    @events = events
    @client = self.getClient(options["target"])
    bill = self.generateBill(@client)
    return bill
  end

  def self.getClient( query ) 
    client = nil
    @clients.each do |c|
      buildQ = [ c["name"], c["alias"] ].join("|")
      regex = Regexp.new(buildQ, Regexp::IGNORECASE)
      if regex.match( query ) != nil
        client = c
      end
    end
    return client
  end

  def self.loadClientMatchData( query )
    requestedClients = Array.new
    if query == nil
      @clients.each do |client|
        requestedClients.push(client["name"])
        requestedClients.push(client["alias"])
      end
    else
      requestedClients = Array.new
      @clients.each do |client|
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

  def self.generateBill(client)
    bill = {
      "date_created" => DateTime.now.strftime("%d/%m/%y"),
#      "date_begin"=> @events.dateBegin.strftime("%d/%m/%y"),
 #     "date_end"=> @events.dateEnd.strftime("%d/%m/%y"),
      "billed_to" => client,
      "billed_from" => @company,
      "items" => [
                  # eg: { description, duration, rate, total
                 ],
      "sub-total" => 0,
      "tax" => nil,
      "total" => nil
    }    
    # loop events and filter for requested matched
    @events.each do |e|
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
    bill["tax"] = bill["sub-total"] * @company["invoice-tax"]
    bill["total"] = bill["sub-total"] + bill["tax"]
    
    return Array.new << bill;
  end

end



#evts = Extractor.new( "/users/jwijeswww/documents/development.ics", DateTime.parse("01-05-2014"), DateTime.parse("28-05-2014"), ["TTS","MD", "Media Dynamics"] )

#run = Billing.new( evts.data )





