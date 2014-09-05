# encoding: utf-8
require File.join(File.dirname(__FILE__), 'helper')

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

  def test_url_escape
    assert_equal '%E4%B8%8A%E6%B5%B7%E5%B8%82%E5%BE%90%E6%B1%87%E5%8C%BA%E6%BC%95%E6%BA%AA%E5%8C%97%E8%B7%AF1111%E5%8F%B7', Geokit::Inflector.url_escape('上海市徐汇区漕溪北路1111号')
    assert_equal '%C3%BC%C3%B6%C3%A4', Geokit::Inflector.url_escape('üöä')
  end
end
