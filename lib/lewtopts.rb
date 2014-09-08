# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# This is the options handling class for LEWT extensions. It handles translating extension options for usage in the command line
# & library run-times and acts as a sort of wrapper class for this functionality.
#
# ===LEWT's reserved option flags
#
# -x --extract:: what extractor[s] to use
# -p --process:: what processor[s] to use
# -o --render:: what renderer[s] to use
# -t --target:: target
# -s --start:: start target date
# -e --end:: end target date
#
# The user defined values for these options are readable by extensions at runtime.


class LewtOpts < Hash
  
  attr_reader :options, :defaults

  # Sets up this extension.
  def initialize ( extensions, library_options = nil )
    default_options  = {
      :start => {
        :definition => "Start time for LEWT snapshot",
        :default => DateTime.now - 8,
        :type => DateTime,
        :short_flag => "-s"
      },
      :end => {
        :definition => "End time for LEWT snapshot",
        :default => DateTime.now,
        :type => DateTime,
        :short_flag => "-e"
      },
      :target => {
        :definition => "The target to filter data with. In the case of most extensions this will be the target customers but other alternatives are possible",
        :short_flag => "-t",
        :type => String
      },
      :extract => {
        :definition => "The extraction extension(s) LEWT should use to pull data with. This can be a comma separated list for multiple sources",
        :default => "calender",
        :type => String,
        :short_flag => "-x"
      },
      :process => {
        :definition => "The processor extensions LEWT should use to process the data with.",
        :default => "invoice",
        :type => String,
        :short_flag => "-p"
      },
      :render => {
        :definition => "The render(s) LEWT should use to output the data with. This can be a comma separate list for multiple outputs.",
        :default => "liquid_render",
        :type => String,
        :short_flag => "-o"
      }
    }
    
    # gather extension options & merge into LEWTs defaults
    extensions.each do |e|
      if e.options != nil
        default_options.merge!( e.options )
      end
    end

    @defaults = default_options

    # determine if using LEWT from command line (CL) or as a drop in library and parse options accordingly
    if File.basename($0).match(/\.rb/) != nil
      parse_library_options( default_options, library_options )
    else
      parse_command_line_options( default_options )
    end

  end
  
  # handles parsing & translating options in command line mode
  # sets the value of the instantized object equal to the parsed options hash
  # default_options [Hash]:: The default options gathered from all extension & Lewt itself to use in case user supplied values aren't given.
  def parse_command_line_options( default_options )
    options = self
    
    # Parse internal commands before extension commands & options to avoid any conflicts & to avoid extension invocation
    # in case a internal command is called.
    OptionParser.new do |opts|

      default_options.each do | name, details |
        # translate options default value if defined
        if details.key?(:default) == true
          options[name] = details[:default]
        end

        cl_type = details[:type].to_s == "DateTime" ? String : details[:type]
        cl_sub = details[:type].to_s == "DateTime" ? "Date" : details[:type]

        cl_option = "--#{name.to_s.gsub("_","-")} [#{cl_sub}]"

        if details.key?(:short_flag) == true && details.key?(:type) == true
          opts.on( details[:short_flag], cl_option, cl_type, details[:definition] ) do |o|
            options[ name ] = prepare_input( details, o )
          end 
        elsif details.key?(:short_flag) == true && details.key?(:type) == false
          opts.on( details[:short_flag], "--#{name.to_s.gsub("_","-")}", details[:definition] ) do |o|
            options[ name ] = prepare_input( details, o )
          end  
        elsif details.key?(:short_flag) == false 
          opts.on( cl_option, cl_type, details[:definition] ) do |o|
            options[ name ] = prepare_input( details, o )
          end
        end

      end
      
      opts.banner = "Usage: lewt -x EXTRACTOR -p PROCESSOR -o RENDERER"
      
    end.parse!(ARGV)
    
    return options
  end
  
  # handles parsing & translating options in library mode
  # sets the value of the instantized object equal to the parsed options hash
  # default_options [Hash]:: The default options gathered from all extension & Lewt itself to use in case user supplied values aren't given.
  # library_options [Hash]:: Some options translated for use in lib mode
  def parse_library_options ( default_options, library_options )
    options = Hash.new

    default_options.each do | name, details |
      # translate options default value if defined
      if details.key?(:default) == true
        options[name] = details[:default]
      end
    end

    # merge library options with options array
    options.merge!(library_options)
    
    # assign options to self
    options.each do |k,v|
      self[k] = v
    end
  end
  
  # this function basically exists to get around the limited variable initialization functionality of
  # Ruby standard option parser class.
  def prepare_input ( details, value )
    type = details[:type]
    if type == DateTime
      initialized_value = DateTime.parse(value)
    else
      initialized_value = value
    end
    return initialized_value
  end
end
