require 'test/unit'
require 'lib/geokit'

class GeoLocTest < Test::Unit::TestCase #:nodoc: all
  
  def setup
    @loc = Geokit::GeoLoc.new
  end
  
  def test_is_us
    assert !@loc.is_us?
    @loc.country_code = 'US'
    assert @loc.is_us?
  end
  
  def test_success
    assert !@loc.success?
    @loc.success = false
    assert !@loc.success?
    @loc.success = true
    assert @loc.success?
  end
  
  def test_street_number
    @loc.street_address = '123 Spear St.'
    assert_equal '123', @loc.street_number
  end
  
  def test_street_name
    @loc.street_address = '123 Spear St.'
    assert_equal 'Spear St.', @loc.street_name
  end
  
  def test_city
    @loc.city = "san francisco"
    assert_equal 'San Francisco', @loc.city
  end
  
  def test_full_address
    @loc.city = 'San Francisco'
    @loc.state = 'CA'
    @loc.zip = '94105'
    @loc.country_code = 'US'
    assert_equal 'San Francisco, CA, 94105, US', @loc.full_address
    @loc.full_address = 'Irving, TX, 75063, US'
    assert_equal 'Irving, TX, 75063, US', @loc.full_address
  end
  
  def test_hash
    @loc.city = 'San Francisco'
    @loc.state = 'CA'
    @loc.zip = '94105'
    @loc.country_code = 'US'
    @another = Geokit::GeoLoc.new @loc.to_hash    
    assert_equal @loc, @another
  end
  
  def test_all
    assert_equal [@loc], @loc.all
  end
  
  def test_to_yaml
    @loc.city = 'San Francisco'
    @loc.state = 'CA'
    @loc.zip = '94105'
    @loc.country_code = 'US'
    assert_equal( 
      "--- !ruby/object:Geokit::GeoLoc \ncity: San Francisco\ncountry_code: US\nfull_address: \nlat: \nlng: \nprecision: unknown\nprovince: \nstate: CA\nstreet_address: \nsuccess: false\nzip: \"94105\"\n", 
      @loc.to_yaml)
  end
  
end