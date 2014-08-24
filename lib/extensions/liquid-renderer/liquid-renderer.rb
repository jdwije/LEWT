#!/usr/bin/ruby
require "liquid"
require "pdfkit"

class LiquidRenderer < LewtExtension
  
  attr_reader :textTemplate, :htmlTemplate, :pdfTemplate, :stylesheet

  def initialize ()
    super

    @options = {
      :output_method => {
        :definition => "Specify html, text, pdf, or any combination of the three to define output method",
        :default => "text",
        :short_flag => "-m",
        :type => String
      },
      :save_file => {
        :definition => "Specify where to save the output file (required for PDFs)",
        :type => String
      },
      :dump_output => {
        :definition => "Toggle dumping output to console or log",
        :default => true,
        :short_flag => "-d"
      }
    }

    @command_name = "liquid_render"

    register_extension
  end

  def loadTemplates ( template )
    @textTemplate = Liquid::Template::parse( File.open( File.expand_path("../../../templates/#{template}.text.liquid", __FILE__) ).read )
    @htmlTemplate = Liquid::Template::parse( File.open( File.expand_path("../../../templates/#{template}.html.liquid", __FILE__) ).read )
    @stylesheet = File.expand_path('../../../templates/style.css', __FILE__)
  end

  def render ( options, data )
    output = Array.new
    
    # template name is always the same as processor name
    loadTemplates( options["processor"] ) 

    if options["output_method"].match "text"
      data.each do |d|
        output <<  textTemplate.render(d)
      end
    end
    
    if options["output_method"].match "html"
      data.each do |d|
        output <<  htmlTemplate.render(d)
      end
    end
    
    if options["output_method"].match "pdf"
      if options["save_file"] == nil then raise "--save-file flag for #{self.class.name} must be specified when PDF output requested" end

      data.each do |d|
        html = htmlTemplate.render(d)
        kit = PDFKit.new(html, :page_size => 'A4')
        kit.stylesheets << @stylesheet
        savename = options["save_file"] || 'test.pdf'
        file = kit.to_file( savename )
        output << savename
      end
    end
    
    if options["dump_output"] != nil
      output.each do |r|
        puts r
      end
    end

    return output
  end

  def markup
    @markup
  end

end
