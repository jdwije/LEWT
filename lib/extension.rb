###################################
## THE LEWT EXTENSION BASE CLASS ##
###################################
# --------------------------------
#   |  x  |    ***     |  @  |
#   -------     ^      -------
# This class provides some basic 
# structuring for LEWT extensions 
# and additionally adds some meta 
# features to extensions which 
# implement it in order to 
# streamline development of LEWT
# extensions.
#           
#               .............
#              ***************          o o
#             *       o o     o o      o   o   o o  
#             *  o o      o o     o   o     o o   o o >
#             (**************)     o o              
#                   .....
#********************************
      

class LewtExtension
  
  attr_reader :stash_path, :user_settings
  
  # Global container of ALL extensions invocation names 
  @@extensions = []
  
  def initialize
    path = File.expand_path( "../config/settings.yml", __FILE__ )
    core_settings = YAML.load_file( path )
    @stash_path = core_settings['stash_path'] || File.expand_path('../config', __FILE__)
    @settings = YAML.load_file( @stash_path + '/settings.yml' )
    registerExtension
  end
  
  protected

  def registerExtension 
    @@extensions << self.class.name
  end
  
end
