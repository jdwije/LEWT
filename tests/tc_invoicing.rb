require "test/unit"
load "../lib/extractor.rb"
load "../lib/invoicer.rb"
 
class ClientInvoicing < Test::Unit::TestCase

  def initialize 
    
  end

  def test_extractInvoice
    assert_equal( 4, SimpleNumber.new(2).add(2) )
    assert_equal(6, SimpleNumber.new(2).multiply(3) )
  end
end
