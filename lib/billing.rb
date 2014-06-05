#!/usr/bin/env ruby

# @class: ClientInvoicing 
#
# Takes an array of EventDataStructure objects and processes them into an invoice for the
# 'recipientClient' which you can configure in ./config/clients.yaml. The resulting invoice
# is structured YAML, it can be converted and prettified to MARKDOWN.
require "yaml"

load "./lib/extractor.rb"
load "./lib/formatter.rb"

class Billing
  
  def initialize ( eventData, target = nil )
    @events = eventData
    @clients = YAML.load_file('./config/clients.yaml')
    @company = YAML.load_file('./config/company.yaml')
    @target = target
    return self.doInvoicing
  end

  # handles the invoicing workflow for you!
  def doInvoicing
    @clients.each do |client|
      # only operate on specified 'target' client but default to all if none given on init
      if @target == nil || @target.include?( client["name"] ) || @target.include?(client["alias"])
        bill = self.generateBill(client)
        form = RenderInvoice.new( bill )
      end
    end
  end

  def generateBill(client)
    bill = {
      "date_created" => DateTime.now.strftime("%d/%m/%y"),
      "date_begin"=> @events.dateBegin.strftime("%d/%m/%y"),
      "date_end"=> @events.dateEnd.strftime("%d/%m/%y"),
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
      if [ client["name"], client["alias"] ].include?(e.summary)
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
    end     
    bill["tax"] = bill["sub-total"] * @company["invoice-tax"]
    bill["total"] = bill["sub-total"] + bill["tax"]
    return bill;
  end

end



#evts = Extractor.new( "/users/jwijeswww/documents/development.ics", DateTime.parse("01-05-2014"), DateTime.parse("28-05-2014"), ["TTS","MD", "Media Dynamics"] )

#run = Billing.new( evts.data )





