require File.join(File.dirname(__FILE__), 'helper')

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
    @loc.city = 'san francisco'
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
    @loc.state_code = 'CA'
    @loc.zip = '94105'
    @loc.country_code = 'US'

    yaml = YAML.parse(@loc.to_yaml)
    case yaml.class.to_s
    when 'YAML::Syck::Map', 'Syck::Map'
      tag = yaml.type_id
      children = yaml.value.sort_by{|k, v| k.value}.flatten.map(&:value)
    when 'Psych::Nodes::Mapping'
      tag = yaml.tag
      children = yaml.children.map(&:value)
    when 'Psych::Nodes::Document'
      tag = yaml.root.tag
      children = yaml.root.children.map(&:value)
    end
    assert_match /.*object:Geokit::GeoLoc$/, tag
    assert_equal [
      'city', 'San Francisco',
      'country_code', 'US',
      'full_address', '',
      'lat', '',
      'lng', '',
      'precision', 'unknown',
      'province', '',
      'state', '',
      'state_code', 'CA',
      'state_name', '',
      'street_address', '',
      'street_name', '',
      'street_number', '',
      'sub_premise', '',
      'success', 'false',
      'zip', '94105'
    ], children
  end

  def test_neighborhood
    @loc.neighborhood = 'SoMa'
    assert_equal @loc.neighborhood, 'SoMa'
  end
end
