# encoding: utf-8

require 'test/unit'
require 'geokit'

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

  def test_url_enconde_with_unicode
    assert_equal "Park+Alle+289R%2C+2605+Br%C3%B8ndby%2C+Denmark", Geokit::Inflector.url_escape('Park Alle 289R, 2605 Brøndby, Denmark')
  end
  

end
