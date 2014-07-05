#!/usr/bin/env ruby

# Test Cases for the Billing core extension.
# ./lib/extension.rb
#
# Written by: jdw <4 July 2014>
#
# ********************************************
require "../lib/extension.rb"
require "test/unit"
load "../lib/extensions/billing/billing.rb"

 
class TestBilling < Test::Unit::TestCase

  def  test_initialize
    billing = Billing.new
    assert_kind_of( Array || Hash , billing.customers, "@clients is not an *Array*")
    assert_kind_of( Hash, billing.enterprise, "@company not a *Hash*")
  end

  
  
end






