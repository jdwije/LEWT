# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

module LEWT


  # The LEWTBook is used by extractors as a generic data structure to adhere to when
  # returning there results.
  # It follows a basic *general ledger* format without the double-entry book keeping.
  #
  # ===Usage:
  #
  # lewtbook = LEWTBook.new()
  # lewtbook.add_row( LEWTLedger.new( params, ... ) )
  #
  class LEWTBook < Array
    # adds a row to this element as per array.push. only accespts LEWTLedger objects as entries.
    # element [LEWTLedger]:: An initialised LEWTLedger object containing your data.  
    def push ( element )
      if element.kind_of?(LEWT::LEWTLedger)
        self.class.superclass.instance_method(:push).bind(self).call element
      else
        raise TypeError, "Class #{self.class.name} only accepts LEWT::LEWTLedger objects as its contents"
      end
    end
  end

end
