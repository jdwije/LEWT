#!/usr/bin/env ruby

# Test Cases for the LewtExtension base class.
# ./lib/extension.rb
#
# Written by: jdw <4 July 2014>
#
# ********************************************

require "test/unit"
load "../lib/extension.rb"

 
class TestLewtExtension < Test::Unit::TestCase

  def  test_initialize
    lewt_object = LewtExtension.new
    assert_kind_of( String, lewt_object.lewt_stash, "lewt_stash not a *String*")
    assert_kind_of( Hash, lewt_object.lewt_settings, "lewt_settings not a *Hash*")
    assert_kind_of( Array, lewt_object.lewt_extensions, "@@lewt_extensions not an *Array*")
  end

  def test_register_extension
    lewt_object = LewtExtension.new
    lewt_object.send(:register_extension, "test_extension")
    assert_kind_of( String, lewt_object.lewt_extensions[0]["cmd"], "LEWT extensions not registering proper 'cmd' string")
    assert_kind_of( LewtExtension, lewt_object.lewt_extensions[0]["ext"], "LEWT extension not being referenced properly")
  end

end






