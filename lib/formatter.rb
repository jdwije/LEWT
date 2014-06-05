#!/usr/bin/ruby
require "liquid"




class RenderInvoice

  def initialize ( invoice_data )

    file = File.open("./templates/invoice.plain-text.liquid", "rb")
    contents = file.read

    @template = Liquid::Template::parse(contents);
    puts @template.render(invoice_data)
    
  end
end
