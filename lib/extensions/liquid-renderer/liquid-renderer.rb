#!/usr/bin/ruby
require "liquid"

class LiquidRenderer

  def initialize ()
    readTextTemplate = File.open( File.expand_path('../../../templates/invoice.plain-text.liquid', __FILE__) ).read
    @@textTemplate = Liquid::Template::parse(readTextTemplate);
    @@htmlTemplate = Liquid::Template::parse( File.open( File.expand_path('../../../templates/invoice.html.liquid', __FILE__) ).read );
  end

  def registerHandlers
    return {
      "initialize" => method(:setOptions),
      "render" => method(:renderOutput)
    }
  end
  
  def renderOutput ( data, options )
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
        kit = PDFKit.new(html, :page_size => 'Letter')
        # kit.stylesheets << @stylesheet
        savename = 'test.pdf'
        file = kit.to_file(savename)
        output << savename
      end
      puts output
    end

    if options["output"] != nil
      output.each do |r|
        puts r
      end
    end

    return output
  end

  def setOptions( cmd, arg, opts, defaults )
    defaults["output_method"] = "text"
    @cmd = cmd
    @arg = arg

    opts.on("-m", "--output-method [STRING]", String, "Define output method id 'html','text'") do |output_method|
      defaults["output_method"] = output_method
    end

    opts.on("-o", "--dump-output", "Dumps output to the console") do |output|
      defaults["output"] = output
    end

    return {
      "options" => opts,
      "defaults" => defaults
    }
  end

  def markup
    @markup
  end

end


LiquidRenderer.new
