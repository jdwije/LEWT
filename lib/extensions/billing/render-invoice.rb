#!/usr/bin/ruby
require "liquid"


class InvoiceRenderer
  def initialize ( invoice_data )
    file = File.open("./templates/invoice.plain-text.liquid", "rb")
    contents = file.read
    @template = Liquid::Template::parse(contents);
    @markup = Array.new.push @template.render(invoice_data)
  end

  def markup
    @markup
  end

end
