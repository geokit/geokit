require 'spec_helper'

describe "Geocoder" do
  
  after(:each) do
    Geokit::Geocoders.google_client_id = nil
    Geokit::Geocoders.google_premier_secret_key = nil
    Geokit::Geocoders::google = nil
  end
  

  describe "self.google_client_id" do
    it "should be nil by default and settable" do
      Geokit::Geocoders.google_client_id.should == nil
      Geokit::Geocoders.google_client_id = 'abc'
      Geokit::Geocoders.google_client_id.should == 'abc'
    end
  end
  
  describe "self.google_premier_secret_key" do
    it "should be nil by default and settable" do
      Geokit::Geocoders.google_premier_secret_key.should == nil
      Geokit::Geocoders.google_premier_secret_key = 'abc123'
      Geokit::Geocoders.google_premier_secret_key.should == 'abc123'
    end
  end

  describe "#sign_url" do
    it "should encrypt the url" do
      expected = 'http://maps.googleapis.com/maps/api/geocode/json?address=New+York&sensor=false&client=clientID&signature=KrU1TzVQM7Ur0i8i7K3huiw3MsA='
      actual = Geokit::Geocoders::Geocoder.sign_url('http://maps.googleapis.com/maps/api/geocode/json?address=New+York&sensor=false&client=clientID','vNIXE0xscrmjlyV-12Nj_BvUPaw=')
      actual.should == expected
    end
    
    it "xml example" do
      secret = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
      url = "http://maps.googleapis.com/maps/api/geocode/xml?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&client=gme-cenx&sensor=false"
      expected = "http://maps.googleapis.com/maps/api/geocode/xml?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&client=gme-cenx&sensor=false&signature=1LZ2Iz3gtt-OH0uIv0nJBFGN8E8="
      Geokit::Geocoders::Geocoder.sign_url(url,secret).should == expected
    end
    
  end
  
  describe "#urlsafe_decode64" do
    it "should deal with - and +" do
      Geokit::Geocoders::Geocoder.urlsafe_decode64("a-b+c-d+").should == "k\346\376s\347~"
    end
  end

  describe "#urlsafe_encode64" do
    it "should deal with - and +" do
      Geokit::Geocoders::Geocoder.urlsafe_encode64("k\346\376s\347~").should == "a-b-c-d-\n"
    end
  end
  
  describe "GoogleGeocoder3#geocode_url" do
    
    it "should use default if not premier" do
      Geokit::Geocoders::google = 'abc123'
      expected = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=Ottawa"
      Geokit::Geocoders::GoogleGeocoder3.geocode_url('Ottawa',{}).should == expected
    end
    
    it "should use client if premier" do
      Geokit::Geocoders.google_client_id = 'gme-cenx'
      Geokit::Geocoders.google_premier_secret_key = 'ciK-I4AWUmFx5jBRIjtrL6hDC04='
      expected = "http://maps.googleapis.com/maps/api/geocode/json?address=Ottawa&client=gme-cenx&sensor=false&oe=utf-8&signature=VG4njf1Yo59tnEvwPAMlgOoj4_0="
      Geokit::Geocoders::GoogleGeocoder3.geocode_url('Ottawa',{}).should == expected
    end
    
  end

  describe "sorting results" do
    let(:raw_results) {
      {
        "results" => [
          { "formatted_address" => '1-First Rooftop Place',
            "geometry" => {"location_type" => "ROOFTOP", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '2-Second Rooftop Place',
            "geometry" => {"location_type" => "ROOFTOP", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '7-First Approximate Place',
            "geometry" => {"location_type" => "APPROXIMATE", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '8-First Approximate Place',
            "geometry" => {"location_type" => "APPROXIMATE", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '5-First Geometric-Center Place',
            "geometry" => {"location_type" => "GEOMETRIC_CENTER", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '6-Second Geometric-Center Place',
            "geometry" => {"location_type" => "GEOMETRIC_CENTER", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '3-First Range-Interpolated Place',
            "geometry" => {"location_type" => "RANGE_INTERPOLATED", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []},

          { "formatted_address" => '4-Second Range-Interpolated Place',
            "geometry" => {"location_type" => "RANGE_INTERPOLATED", "location" => {"lat" => 1.0, "lng" => 1.0}},
            'address_components' => []}
        ]
      }
    }

    it "returns the most relevant result first" do
      JSON.stub!(:decode).and_return(raw_results)
      JSON.stub!(:parse).and_return(raw_results)

      results = Geokit::Geocoders::GoogleGeocoder3.json2GeoLoc('mock-json-string')

      # first default result should be the first one.
      results.full_address.should == '1-First Rooftop Place'

      # all results should be ordered properly
      results.all[0].full_address.should == '1-First Rooftop Place'
      results.all[1].full_address.should == '2-Second Rooftop Place'
      results.all[2].full_address.should == '3-First Range-Interpolated Place'
      results.all[3].full_address.should == '4-Second Range-Interpolated Place'
      results.all[4].full_address.should == '5-First Geometric-Center Place'
      results.all[5].full_address.should == '6-Second Geometric-Center Place'
      results.all[6].full_address.should == '7-First Approximate Place'
      results.all[7].full_address.should == '8-First Approximate Place'
    end
  end
  
end
