#!/usr/bin/env ruby

# @class: ClientInvoicing 
#
# Takes an array of EventDataStructure objects and processes them into an invoice for the
# 'recipientClient' which you can configure in ./config/clients.yaml. The resulting invoice
# is structured YAML, it can be converted and prettified to MARKDOWN.

class ClientInvoicing
  
  def initialize ( eventData, target = nil )
    @events = eventData
    @clients = YAML.load_file('config/clients.yaml')
    @target = target
    return self.extractInvoice
  end

  # iterates client bills and saves them to local dir
  def extractInvoice
    @@client.each do |client|
      clientDeets = client[1][0]["client"]
      markdown = self.getMarkdownHeader( clientDeets )
      subtotal = 0;
      tax = 0;
      total = 0

      client[1].each do |bill|
        dStart = bill["eStart"].strftime("%d/%m/%y %H:%M")
        dEnd = bill["eEnd"].strftime("%d/%m/%y %H:%M")
        descriptionAdjust = bill["eDescription"] != "" ? "\n\n" + bill["eDescription"] + "\n\n" : "\n\n"
        markdown <<  "#{dStart} - #{dEnd}: #{ bill['hours']}hrs @ rate $#{bill['client']['rate']} = **$#{bill['cost']}**#{descriptionAdjust}"
        subtotal += bill["cost"]
      end

      tax = subtotal * 0.1
      total = subtotal + tax
      markdown << self.getMarkdownFooter( subtotal, tax, total )
      filepath = clientDeets["invoice_directory"] << clientDeets["name"] << " " << @@dateStart.strftime("%Y-%m-%d") << " " << @@dateEnd.strftime("%Y-%m-%d") << ".md"
      File.open(filepath, 'w+') {|f| f.write(markdown) }
    end
  end



  def getMarkdownFooter( subtotal, tax, total )
    footer = File.open("templates/invoice-footer.md", "rb").read
    footer.gsub! "{subtotal}", subtotal.to_s
    footer.gsub! "{tax}", tax.to_s
    footer.gsub! "{total}", total.to_s
    return footer
  end

  def getMarkdownHeader ( client ) 
    header = File.open("templates/invoice-header.md", "rb").read
    header.gsub! "{from}", @@dateStart.strftime("%d/%m/%y")
    header.gsub! "{to}", @@dateEnd.strftime("%d/%m/%y")
    header.gsub! "{company}", client["name"]
    header.gsub! "{contact}", client['contact']['name']
    header.gsub! "{business_number}", client['business_number'].to_s
    header.gsub! "{address}", "#{client['address']['lines']},  \n#{client['address']['city']}, #{client['address']['postal']},  \n#{client['address']['country']}"
    return header
  end

end




