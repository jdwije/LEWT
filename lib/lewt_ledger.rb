# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# The LEWTBook is used by extractors as a generic data structure to adhere to when
# returning there results.
# It follows a basic *general ledger* format without the double-entry book keeping.
#
# ===Note:
# Ideally I would like to override the Array.push method for LEWTBooks in such a way
# that when LEWTBook.push is called, that when the *if* type check clause is not met
# an error is raised otherwise the element is added via Array.push. I am still not clear
# on the in-and-outs of method riding in ruby so I am adding a new method add_row
# instead to keep things simple for myself.

class LEWTBook < Array

  def add_row ( element )
    if element.class.name == 'LEWTLedger'
      push(element)
    else
      raise TypeError, "Class #{self.class.name} only accepts LEWTLedger objects as its contents"
    end
  end
end

# LEWTLedger is a preformated hash structure that conforms somewhat to a general ledger entry.
#
# ===Keys:
# date_start:: start date the entry occured on
# date_end:: end date the entry occured on
# category:: some sort of general category for this entry i.e: 'Hourly Income', 'Operating Expenses' etc.
# entity:: the entiry with whom this transaction occured with
# description:: a description of the entry
# quantiry:: how many units
# unit_cost:: the cost per unit
# total:: quantity * unit_cost
class LEWTLedger < Hash
  def  initialize ( d_start, d_end, category, entity, desc, quantity, unit_cost, total = nil  )
    self["date_start"] = d_start
    self["date_end"] = d_end
    self["category"] = category
    self["entity"] = entity
    self["description"] = desc
    self["quantity"] = quantity
    self["unit_cost"] = unit_cost
    self["total"] = total || quantity * unit_cost
  end
end
