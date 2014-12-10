require "liquid"
require "pdfkit"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.


module LEWT

  # The Liquid Renderer LEWT Extension handles rendering processed data to TEXT, HTML, and PDF formats using the
  # {liquid templating engine}[http://liquidmarkup.org] at its core. This allows for easy marking up of templates
  # to be used with arbitrary LEWT extensions and processing them into multiple human readable formats on the fly.

  class LiquidRenderer < LEWT::Extension
    
    attr_reader :textTemplate, :htmlTemplate, :pdfTemplate, :stylesheet, :markup

    # Sets up this extension and registers its run-time options.
    def initialize ()
      options = {
        :method => {
          :definition => "Specify html, text, pdf, or any combination of the three to define output method",
          :default => "text",
          :short_flag => "-m",
          :type => String
        },
        :save_path => {
          :definition => "Specify where to save the output file (required for PDFs)",
          :type => String
        },
        :liquid_template => {
          :definition => "Override the template that liquid render should use. Defaults to the template which matches the processor name but you will want to override this if you are using multiple processors.",
          :type => String
        }
      }
      super({:cmd => "liquid_render", :options => options })
    end
    
    # Loads the plaint-text, html, & (optionally) pdf template files of the given template name and parses it with the Liquid class
    # template [String]:: The name of the template to load.
    def load_templates ( template )
      @textTemplate = Liquid::Template::parse( File.open( File.expand_path( lewt_stash  + "/templates/#{template}.text.liquid", __FILE__) ).read )
      @htmlTemplate = Liquid::Template::parse( File.open( File.expand_path( lewt_stash + "/templates/#{template}.html.liquid", __FILE__) ).read )
      @stylesheet = File.expand_path( lewt_stash + '/templates/style.css', __FILE__)
    end

    # Called on LEWT render cycle, this method outputs the data as per a pre-formated liquid template.
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    # data [Array]:: An array of hash data to format.
    def render ( options, data )
      output = Array.new
      # template name is always the same as processor name
      template = options[:liquid_template] != nil ? options[:liquid_template] : options[:process]
      load_templates( template )

      data.each_with_index do |d, i|

        if options[:method].match "text"
          r = textTemplate.render(d)
          if options[:save_path]
            save_name = format_save_name( options, i )
            File.open( save_name, 'w') {|f| f.write r }
            output << save_name
          else
            output << r
          end
        end
        
        if options[:method].match "html"
          r = htmlTemplate.render(d)
          if options[:save_path]
            save_name = format_save_name( options, i )
            File.open( save_name, 'w') {|f| f.write r }
            output << save_name
          else
            output << r
          end
        end
        
        if options[:method].match "pdf"
          raise ArgumentError,"--save-file flag must be specified for PDF output in #{self.class.name}" if !options[:save_path]
          save_name = format_save_name( options, i )
          html = htmlTemplate.render(d)
          kit = PDFKit.new(html, :page_size => 'A4')
          kit.stylesheets << @stylesheet
          file = kit.to_file( save_name )
          output << save_name
        end
      end
      # if options[:dump_output] != false
      #   output.each do |r|
      #     puts r
      #   end
      # end

      return output
    end
    
    protected
    
  end

end
