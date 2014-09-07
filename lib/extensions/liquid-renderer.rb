require "liquid"
require "pdfkit"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.
#
# The Liquid Renderer LEWT Extension handles rendering processed data to TEXT, HTML, and PDF formats using the
# {liquid templating engine}[http://liquidmarkup.org] at its core. This allows for easy marking up of templates
# to be used with arbitrary LEWT extensions and processing them into multiple human readable formats on the fly.

class LiquidRenderer < LewtExtension
  
  attr_reader :textTemplate, :htmlTemplate, :pdfTemplate, :stylesheet

  # Sets up this extension and registers its run-time options.
  def initialize ()
    options = {
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
      },
      :liquid_template => {
        :definition => "Override the template that liquid render should use. Defaults to the template which matches the processor name but you will want to override this if you are using multiple processors.",
        :type => String
      }
    }

    super({:cmd => "liquid_render", :options => options })
  end

  
  def loadTemplates ( template )
    @textTemplate = Liquid::Template::parse( File.open( File.expand_path( lewt_stash  + "/templates/#{template}.text.liquid", __FILE__) ).read )
    @htmlTemplate = Liquid::Template::parse( File.open( File.expand_path( lewt_stash + "/templates/#{template}.html.liquid", __FILE__) ).read )
    @stylesheet = File.expand_path( lewt_stash + '/templates/style.css', __FILE__)
  end

  def render ( options, data )
    output = Array.new
    
    # template name is always the same as processor name
    template = options["liquid_template"] != nil ? options["liquid_template"] : options["proces"]
    loadTemplates( template )

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
