require "yaml"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.
#
# The Store LEWT Extension handles persisting data across sessions. It hooks into the 'process' operation to
# obtain the raw extract data, likewise it hooks into 'render' to get the process data. Whilst in 'render' it
# also handles writing the data to the file-system, so to save data you must invoke it with the --render flag!
# The data is saved to some configurable paths (see source code).
#
# Furthermore store can also re-extract previously persisted data from the file system for re-use! This is handy
# if you need to re-generate some output (ie: an invoice that required a quick edit), or if you would like to use
# store data built up overtime for bulk operations such as analytics & reporting.

class Store < LewtExtension
  
  # Sets up this extensions command name and run-time options.
  def initialize
    options = {
      :store_archive => {
        :definition => "The sub-folder within lewt_store to save data in",
        :default => "",
        :type => String
      },
      :store_file => {
        :definition => "File name to save as",
        :default => "store-#{DateTime.now.to_s}.yml",
        :type => String
      },
      :store_target => {
        :definition => "Tell store whether to save either the 'extract' or 'process' data",
        :default => "process",
        :type => String
      }
    }
    super({:cmd => "store", :options => options})
  end  

  # This method is not yet implemented. This method (should) extracts previously stored data for reuse.
  # options [Hash]:: A hash that is passed to this extension by the main LEWT program containing ru-time options.
  def extract( options )
    
  end
  
  # Captures the extract data and converts it to a YML string storing it as a property on this object.
  # Returns an empty array so as not to interupt the process loop.
  # options [Hash]:: A hash that is passed to this extension by the main LEWT program containing ru-time options.
  # data [Hash]:: The extracted data as a hash.
  def process( options, data )
    @extractData = data.to_yaml
    return []
  end

  # Captures proess data and converts it to a YML string. This method also handles the
  # actual writing of data to the file system. The options 'store_target' toggles exract or
  # process targeting.
  # options [Hash]:: A hash that is passed to this extension by the main LEWT program containing ru-time options.
  # data [Array]:: The processed data as an array of hashes.
  def render( options, data )
    save_path = lewt_settings["store_path"] + options["store_archive"]
    @processData = data.to_yaml
    name = options["store_file"]
    ymlData = options["store_target"] == "extract" ? @extractData : @processData
    self.store(ymlData, save_path, name)
  end

  protected
  
  # Writes the given YAML string to a file at path/name.yml, this method will overwrite the
  # file if it already exists.
  # yml [String]:: A YAML string of data.
  # path [String]:: The path to store too.
  # name [String]:: The name of the file to save as.
  def store ( yml, path, name  )
    storefile = File.new( path + name.gsub(".yml", "") + ".yml", "w")
    storefile.puts(yml)
    storefile.close
    return ["storeid"]
  end

end


