#!/usr/bin/env ruby

# Test Cases for the Billing core extension.
# ./lib/extension.rb
#
# Written by: jdw <4 July 2014>
#
# ********************************************
require "test/unit"
require_relative "../lib/lewt.rb"
 
class TestLewt < Test::Unit::TestCase

  def test_initialize
    lewt = LEWT::Lewt.new( { :target => "ACME" } )
    assert_kind_of( LEWT::Lewt, lewt, "Failed to initialize Lewt object.")
  end

  def test__methods
    lewt = LEWT::Lewt.new( { :target => "ACME" } )
    assert_kind_of( Hash, lewt.get_client("ACME"), "get_client method failing, make sure ACME is in your clients file when running tests")
  end

  def test_matching
    # valid LEWT command line option delimiter are ',' '+' ':'
    assert_not_equal( nil, "bcd+abc".match(LEWT::Lewt::OPTION_DELIMITER_REGEX) )
    assert_not_equal( nil, "bcd,abc".match(LEWT::Lewt::OPTION_DELIMITER_REGEX) )
    assert_not_equal( nil, "bcd:abc".match(LEWT::Lewt::OPTION_DELIMITER_REGEX) )
  end
  
end






