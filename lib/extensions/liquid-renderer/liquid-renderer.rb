#!/usr/bin/ruby
require "liquid"
require "pdfkit"

class LiquidRenderer < LewtExtension

  def initialize ()
    super
    register_extension("liquid_render")
    readTextTemplate = File.open( File.expand_path('../../../templates/invoice.plain-text.liquid', __FILE__) ).read
    @@textTemplate = Liquid::Template::parse(readTextTemplate);
    @@htmlTemplate = Liquid::Template::parse( File.open( File.expand_path('../../../templates/invoice.html.liquid', __FILE__) ).read );
    @@stylesheet = File.expand_path('../../../templates/style.css', __FILE__)
  end

  def render ( options, data )
    output = Array.new
    if options["output_method"] == "text"
      data.each do |d|
        output <<  @@textTemplate.render(d)
      end
    elsif options["output_method"] == "html"
      data.each do |d|
        output <<  @@htmlTemplate.render(d)
      end
    elsif options["output_method"] == "pdf"      
      data.each do |d|
        html = @@htmlTemplate.render(d)
        kit = PDFKit.new(html, :page_size => 'A4')
        kit.stylesheets << @@stylesheet
        savename = options["save_name"] || 'test.pdf'
        file = kit.to_file( savename )
        output << savename
      end
    end

    if options["output"] != nil
      output.each do |r|
        puts r
      end
    end

    return output
  end

  def register_options ( opts, defaults )
    defaults["output_method"] = "text"

    opts.on("-m", "--output-method [STRING]", String, "Select an output method i.e: 'html' or 'html|text|pdf'") do |output_method|
      defaults["output_method"] = output_method
    end
    
    opts.on("-s", "--save-file [STRING]", String, "Specify a file name for the output to be dumped to") do |save_name|
      defaults["save_name"] = save_name
    end

    opts.on("-d", "--dump-output", "Toggle dumping output to console.") do |dump_output|
      defaults["console_dump_output"] = dump_output
    end

    return { "options" => opts, "defaults" => defaults }
  end

  def markup
    @markup
  end

end


LiquidRenderer.new
