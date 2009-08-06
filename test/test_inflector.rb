# encoding: utf-8

require 'test/unit'
require 'lib/geokit'

class InflectorTest < Test::Unit::TestCase #:nodoc: all
  
  def test_titleize
    assert_equal 'Sugar Grove', Geokit::Inflector.titleize('Sugar Grove')
    assert_equal 'Sugar Grove', Geokit::Inflector.titleize('Sugar grove')
    assert_equal 'Sugar Grove', Geokit::Inflector.titleize('sugar Grove')
    assert_equal 'Sugar Grove', Geokit::Inflector.titleize('sugar grove')
  end
  
  def test_titleize_with_unicode
    assert_equal 'Borås', Geokit::Inflector.titleize('Borås')
    assert_equal 'Borås', Geokit::Inflector.titleize('borås')
    assert_equal 'Borås (Abc)', Geokit::Inflector.titleize('Borås (Abc)')
    assert_equal 'Borås (Abc)', Geokit::Inflector.titleize('Borås (abc)')
    assert_equal 'Borås (Abc)', Geokit::Inflector.titleize('borås (Abc)')
    assert_equal 'Borås (Abc)', Geokit::Inflector.titleize('borås (abc)')
  end
   
end
