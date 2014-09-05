# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'helper')

class YandexGeocoderTest < BaseGeocoderTest #:nodoc: all
  YANDEX_FULL = <<-EOF.strip
    {"response":{"GeoObjectCollection":{"metaDataProperty":{"GeocoderResponseMetaData":{"request":"Москва, улица Новый Арбат, дом 24","found":"1","results":"10"}},"featureMember":[{"GeoObject":{"metaDataProperty":{"GeocoderMetaData":{"kind":"house","text":"Россия, Москва, улица Новый Арбат, 24","precision":"exact","AddressDetails":{"Country":{"AddressLine":"Москва, улица Новый Арбат, 24","CountryNameCode":"RU","CountryName":"Россия","Locality":{"LocalityName":"Москва","Thoroughfare":{"ThoroughfareName":"улица Новый Арбат","Premise":{"PremiseNumber":"24"}}}}}}},"description":"Москва, Россия","name":"улица Новый Арбат, 24","boundedBy":{"Envelope":{"lowerCorner":"37.585565 55.751928","upperCorner":"37.589662 55.754238"}},"Point":{"pos":"37.587614 55.753083"}}}]}}}
  EOF

  YANDEX_REGION = <<-EOF.strip
    {"response":{"GeoObjectCollection":{"metaDataProperty":{"GeocoderResponseMetaData":{"request":"Ростов-на-Дону, ул. Станиславского, д.21","found":"1","results":"10"}},"featureMember":[{"GeoObject":{"metaDataProperty":{"GeocoderMetaData":{"kind":"house","text":"Россия, Ростовская область, город Ростов-на-Дону, улица Станиславского, 21","precision":"exact","AddressDetails":{"Country":{"AddressLine":"Ростовская область, город Ростов-на-Дону, улица Станиславского, 21","CountryNameCode":"RU","CountryName":"Россия","AdministrativeArea":{"AdministrativeAreaName":"Ростовская область","Locality":{"LocalityName":"город Ростов-на-Дону","Thoroughfare":{"ThoroughfareName":"улица Станиславского","Premise":{"PremiseNumber":"21"}}}}}}}},"description":"город Ростов-на-Дону, Ростовская область, Россия","name":"улица Станиславского, 21","boundedBy":{"Envelope":{"lowerCorner":"39.701349 47.214507","upperCorner":"39.705446 47.217298"}},"Point":{"pos":"39.703398 47.215903"}}}]}}}
  EOF

  YANDEX_CITY = <<-EOF.strip
    {"response":{"GeoObjectCollection":{"metaDataProperty":{"GeocoderResponseMetaData":{"request":"город Москва","found":"1","results":"10"}},"featureMember":[{"GeoObject":{"metaDataProperty":{"GeocoderMetaData":{"kind":"locality","text":"Россия, Москва","precision":"other","AddressDetails":{"Country":{"AddressLine":"Москва","CountryNameCode":"RU","CountryName":"Россия","Locality":{"LocalityName":"Москва"}}}}},"description":"Россия","name":"Москва","boundedBy":{"Envelope":{"lowerCorner":"37.182743 55.490667","upperCorner":"37.964969 56.01074"}},"Point":{"pos":"37.617761 55.755773"}}}]}}}
  EOF

  YANDEX_NO_RESULTS = <<-EOF.strip
    {"response":{"GeoObjectCollection":{"metaDataProperty":{"GeocoderResponseMetaData":{"request":"ZZ, ZZ, ZZ","found":"0","results":"10"}},"featureMember":[]}}}
  EOF

  def setup
    super
    @full_address = 'Москва, улица Новый Арбат, дом 24'
    @address = 'город Москва'
  end

  # the testing methods themselves
  def test_yandex_full_address
    response = MockSuccess.new
    response.expects(:body).returns(YANDEX_FULL)
    url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector.url_escape(@full_address)}&format=json"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::YandexGeocoder.geocode(@full_address)

    assert_equal 'yandex', res.provider
    assert_equal 'улица Новый Арбат, 24', res.street_address
    assert_equal 'Москва', res.city
    assert_equal 55.753083, res.lat
    assert_equal 37.587614, res.lng
    assert_equal 'RU', res.country_code
    assert res.success
  end

  def test_yandex_full_address_with_region
    region_address = 'Ростов-на-Дону, ул. Станиславского, д.21'
    response = MockSuccess.new
    response.expects(:body).returns(YANDEX_REGION)
    url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector.url_escape(region_address)}&format=json"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::YandexGeocoder.geocode(region_address)

    assert_equal 'yandex', res.provider
    assert_equal 'улица Станиславского, 21', res.street_address
    assert_equal 'город Ростов на Дону', res.city
    assert_equal 'Ростовская область', res.state
    assert_equal 47.215903, res.lat
    assert_equal 39.703398, res.lng
    assert_equal 'RU', res.country_code
    assert res.success
  end

  def test_yandex_city
    response = MockSuccess.new
    response.expects(:body).returns(YANDEX_CITY)
    url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector.url_escape(@address)}&format=json"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::YandexGeocoder.geocode(@address)

    assert_equal 'yandex', res.provider
    assert_equal 'city', res.precision
    assert_equal 'Москва', res.city
    assert_equal 55.755773, res.lat
    assert_equal 37.617761, res.lng
    assert_equal 'RU', res.country_code
    assert res.success
  end

  def test_no_results
    no_results_address = 'ZZ, ZZ, ZZ'
    # no_results_full_hash = {:street_address=>"ZZ", :city=>"ZZ", :state=>"ZZ"}
    # no_results_full_loc = Geokit::GeoLoc.new(no_results_full_hash)

    response = MockSuccess.new
    response.expects(:body).returns(YANDEX_NO_RESULTS)
    url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector.url_escape(no_results_address)}&format=json"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    result = Geokit::Geocoders::YandexGeocoder.geocode(no_results_address)
    assert_equal ',', result.ll
  end
end
