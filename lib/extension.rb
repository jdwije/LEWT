###################################
## THE LEWT EXTENSION BASE CLASS ##
###################################
# --------------------------------
# This class provides some basic 
# structuring for LEWT extensions 
# and additionally adds some meta 
# features to extensions which 
# implement it in order to 
# streamline development of LEWT
# extensions.
#********************************
      

class LewtExtension
  
  # LEWT Stash is the user configured stash path where all extensions, config file, templates etc are stored.
  attr_reader :lewt_stash
  
  # Global container of ALL extensions invocation names 
  @@call_mappings = {
    "extractors" => null
    "processors" => null
    "renderers" => null
  }

  def initialize
    path = File.expand_path( "../config/settings.yml", __FILE__ )
    core_settings = YAML.load_file( path )
    @@lewt_stash = core_settings['stash_path'] || File.expand_path('../config', __FILE__)
    @settings = YAML.load_file( @@lewt_stash + '/settings.yml' )
  end
  
  protected

end

class Extractor < LewtExtension
  def initialize
    
  end
end

class Processor < LewtExtension
  
end

class Renderer < LewtExtension
  
end
