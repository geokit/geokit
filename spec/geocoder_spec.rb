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
  
end