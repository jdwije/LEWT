#!/usr/bin/ruby

# The Lewt ledger is used by extractors as a generic data structure to adhere to when
# returning there results.
# It follows a basic *general ledger* format without the double-entry book keeping.
class LEWTBooks < Array

  # @NOTE!!
  # Ideally I would like to override the Array.push method for LEWTBooks in such a way
  # that when LEWTBooks.push is called, that when the *if* type check clause is not met
  # an error is raised otherwise the element is added via Array.push. I am still not clear
  # on the in-and-outs of method riding in ruby so I am adding a new method add_row
  # instead to keep things simple for myself.
  def add_row ( element )
    if element.class.name == 'LEWTLedger'
      push(element)
    else
      raise TypeError, "Class #{self.class.name} only accepts LEWTLedger objects as its contents"
    end
  end
end


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
