# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'helper')

class WoosmapGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    @base_url = "https://api.woosmap.com/localities/geocode"

    # This is used to filter the results only in France country.
    @components = { country: "fr" }

    @full_street_address = "1 Aveneu Claude Vellefaux, 75010 Paris"
    @street_address = "Aveneu Claude Vellefaux, 75010 Paris"
    @square_address = "Place Georges-Pompidou, 75004 Paris"
    @town_address = "Lyon"
    @zip_code_address = "75018"
  end

  def test_woosmap_api_key
    geocoder_class.api_private_key = nil
    geocoder_class.api_key = 'someKey'
    url = geocoder_class.send(:build_url, 'address=New+York')
    geocoder_class.api_key = nil
    assert_equal "#{@base_url}?address=New+York&key=someKey", url
  end

  def test_woosmap_insecure_url
    Geokit::Geocoders.secure = false
    url = geocoder_class.send(:build_url, 'address=New+York')
    Geokit::Geocoders.secure = true
    base_url_http_protocol = @base_url.gsub(/^https:/, 'http:')
    assert_equal "#{base_url_http_protocol}?address=New+York", url
  end

  def test_woosmap_full_street_address
    url = "https://api.woosmap.com/localities/geocode?address=1+Aveneu+Claude+Vellefaux%2C+75010+Paris&components=country%3Afr"
    TestHelper.expects(:last_url).with(url)

    res = geocode(@full_street_address, :woosmap_full_street_address, components: @components)
    assert_equal true, res.success
    assert_equal "woosmap", res.provider
    assert_equal "FR", res.country_code
    assert_equal "France", res.country
    assert_equal "Paris", res.city
    assert_equal "75010", res.zip
    assert_equal "1", res.street_number
    assert_equal "Avenue Claude Vellefaux", res.street_name
    assert_equal "1 Avenue Claude Vellefaux", res.street_address
    assert_equal "1 Avenue Claude Vellefaux, 75010, Paris", res.full_address
    assert_equal "1 Avenue Claude Vellefaux, 75010, Paris", res.formatted_address
    assert_equal 48.872907, res.lat
    assert_equal 2.369788, res.lng
  end

  def test_woosmap_street_address
    url = "https://api.woosmap.com/localities/geocode?address=Aveneu+Claude+Vellefaux%2C+75010+Paris&components=country%3Afr"
    TestHelper.expects(:last_url).with(url)

    res = geocode(@street_address, :woosmap_street_address, components: @components)
    assert_equal true, res.success
    assert_equal "woosmap", res.provider
    assert_equal "FR", res.country_code
    assert_equal "France", res.country
    assert_equal "Paris", res.city
    assert_equal "75010", res.zip
    assert_equal "", res.street_number
    assert_equal "Avenue Claude Vellefaux", res.street_name
    assert_equal "Avenue Claude Vellefaux", res.street_address
    assert_equal "Avenue Claude Vellefaux, 75010, Paris", res.full_address
    assert_equal "Avenue Claude Vellefaux, 75010, Paris", res.formatted_address
    assert_equal 48.87415, res.lat
    assert_equal 2.370488, res.lng
  end

  def test_woosmap_square_address
    url = "https://api.woosmap.com/localities/geocode?address=Place+Georges-Pompidou%2C+75004+Paris&components=country%3Afr"
    TestHelper.expects(:last_url).with(url)

    res = geocode(@square_address, :woosmap_square_address, components: @components)
    assert_equal true, res.success
    assert_equal "woosmap", res.provider
    assert_equal "FR", res.country_code
    assert_equal "France", res.country
    assert_equal "Paris", res.city
    assert_equal "75004", res.zip
    assert_equal "", res.street_number
    assert_equal "Place Georges Pompidou", res.street_name
    assert_equal "Place Georges Pompidou", res.street_address
    assert_equal "Place Georges Pompidou, 75004, Paris", res.full_address
    assert_equal "Place Georges Pompidou, 75004, Paris", res.formatted_address
    assert_equal 48.860307, res.lat
    assert_equal 2.351132, res.lng
  end

  def test_woosmap_town_address
    url = "https://api.woosmap.com/localities/geocode?address=Lyon&components=country%3Afr"
    TestHelper.expects(:last_url).with(url)

    res = geocode(@town_address, :woosmap_town_address, components: @components)
    assert_equal true, res.success
    assert_equal "woosmap", res.provider
    assert_equal "FR", res.country_code
    assert_equal "France", res.country
    assert_equal "Lyon", res.city
    assert_equal %w[
      69000 69001 69002 69003 69004 69005 69006 69007 69008 69009
    ], res.zip
    assert_equal nil, res.street_number
    assert_equal nil, res.street_name
    assert_equal nil, res.street_address
    assert_equal "Rhône", res.state
    assert_equal "Lyon, Rhône", res.full_address
    assert_equal "Lyon, Rhône", res.formatted_address
    assert_equal 45.757813618627125, res.lat
    assert_equal 4.832011318544403, res.lng
  end

  def test_woosmap_zip_code_address
    url = "https://api.woosmap.com/localities/geocode?address=75018&components=country%3Afr"
    TestHelper.expects(:last_url).with(url)

    res = geocode(@zip_code_address, :woosmap_zip_code_address, components: @components)
    assert_equal true, res.success
    assert_equal "woosmap", res.provider
    assert_equal "FR", res.country_code
    assert_equal "France", res.country
    assert_equal "Paris Xviii", res.city
    assert_equal "75018", res.zip
    assert_equal nil, res.street_number
    assert_equal nil, res.street_name
    assert_equal nil, res.street_address
    assert_equal "Paris", res.state
    assert_equal "75018, Paris XVIII", res.full_address
    assert_equal "75018, Paris XVIII", res.formatted_address
    assert_equal 48.892228, res.lat
    assert_equal 2.348215915105388, res.lng
  end
end
