#!/usr/bin/env ruby

# Test Cases for the Billing core extension.
# ./lib/extension.rb
#
# Written by: jdw <4 July 2014>
#
# ********************************************
require "test/unit"
require "../lib/lewt.rb"
 
class TestLewt < Test::Unit::TestCase

  def test_initialize
    lewt = Lewt.new
    assert_kind_of( Lewt, lewt, "Failed to initialize Lewt object.")
  end
  
end






