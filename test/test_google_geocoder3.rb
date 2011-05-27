require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::google = 'Google'

class GoogleGeocoder3Test < BaseGeocoderTest #:nodoc: all
  
  GOOGLE3_FULL=%q/
  {
    "status": "OK",
    "results": [ {
      "types": [ "street_address" ],
      "formatted_address": "100 Spear St, San Francisco, CA 94105, USA",
      "address_components": [ {
        "long_name": "100",
        "short_name": "100",
        "types": [ "street_number" ]
      }, {
        "long_name": "Spear St",
        "short_name": "Spear St",
        "types": [ "route" ]
      }, {
        "long_name": "San Francisco",
        "short_name": "San Francisco",
        "types": [ "locality", "political" ]
      }, {
        "long_name": "San Francisco",
        "short_name": "San Francisco",
        "types": [ "administrative_area_level_3", "political" ]
      }, {
        "long_name": "San Francisco",
        "short_name": "San Francisco",
        "types": [ "administrative_area_level_2", "political" ]
      }, {
        "long_name": "California",
        "short_name": "CA",
        "types": [ "administrative_area_level_1", "political" ]
      }, {
        "long_name": "United States",
        "short_name": "US",
        "types": [ "country", "political" ]
      }, {
        "long_name": "94105",
        "short_name": "94105",
        "types": [ "postal_code" ]
      } ],
      "geometry": {
        "location": {
          "lat": 37.7921509,
          "lng": -122.3940000
        },
        "location_type": "ROOFTOP",
        "viewport": {
          "southwest": {
            "lat": 37.7890033,
            "lng": -122.3971476
          },
          "northeast": {
            "lat": 37.7952985,
            "lng": -122.3908524
          }
        }
      }
    } ]
  }
  /.strip

  GOOGLE3_CITY=%q/
  {
    "status": "OK",
    "results": [ {
      "types": [ "locality", "political" ],
      "formatted_address": "San Francisco, CA, USA",
      "address_components": [ {
        "long_name": "San Francisco",
        "short_name": "San Francisco",
        "types": [ "locality", "political" ]
      }, {
        "long_name": "San Francisco",
        "short_name": "San Francisco",
        "types": [ "administrative_area_level_2", "political" ]
      }, {
        "long_name": "California",
        "short_name": "CA",
        "types": [ "administrative_area_level_1", "political" ]
      }, {
        "long_name": "United States",
        "short_name": "US",
        "types": [ "country", "political" ]
      } ],
      "geometry": {
        "location": {
          "lat": 37.7749295,
          "lng": -122.4194155
        },
        "location_type": "APPROXIMATE",
        "viewport": {
          "southwest": {
            "lat": 37.7043396,
            "lng": -122.5474749
          },
          "northeast": {
            "lat": 37.8454521,
            "lng": -122.2913561
          }
        },
        "bounds": {
          "southwest": {
            "lat": 37.7034000,
            "lng": -122.5270000
          },
          "northeast": {
            "lat": 37.8120000,
            "lng": -122.3482000
          }
        }
      }
    } ]
  }
  /.strip
  GOOGLE3_MULTI=%q/
    {
      "status": "OK",
      "results": [ {
        "types": [ "street_address" ],
        "formatted_address": "Via Sandro Pertini, 8, 20010 Mesero MI, Italy",
        "address_components": [ {
          "long_name": "8",
          "short_name": "8",
          "types": [ "street_number" ]
        }, {
          "long_name": "Via Sandro Pertini",
          "short_name": "Via Sandro Pertini",
          "types": [ "route" ]
        }, {
          "long_name": "Mesero",
          "short_name": "Mesero",
          "types": [ "locality", "political" ]
        }, {
          "long_name": "Milan",
          "short_name": "MI",
          "types": [ "administrative_area_level_2", "political" ]
        }, {
          "long_name": "Lombardy",
          "short_name": "Lombardy",
          "types": [ "administrative_area_level_1", "political" ]
        }, {
          "long_name": "Italy",
          "short_name": "IT",
          "types": [ "country", "political" ]
        }, {
          "long_name": "20010",
          "short_name": "20010",
          "types": [ "postal_code" ]
        } ],
        "geometry": {
          "location": {
            "lat": 45.4966218,
            "lng": 8.8526940
          },
          "location_type": "RANGE_INTERPOLATED",
          "viewport": {
            "southwest": {
              "lat": 45.4934754,
              "lng": 8.8495559
            },
            "northeast": {
              "lat": 45.4997707,
              "lng": 8.8558512
            }
          },
          "bounds": {
            "southwest": {
              "lat": 45.4966218,
              "lng": 8.8526940
            },
            "northeast": {
              "lat": 45.4966243,
              "lng": 8.8527131
            }
          }
        },
        "partial_match": true
      },
      {
         "types": [ "route" ],
         "formatted_address": "Via Sandro Pertini, 20010 Ossona MI, Italy",
         "address_components": [ {
           "long_name": "Via Sandro Pertini",
           "short_name": "Via Sandro Pertini",
           "types": [ "route" ]
         }, {
           "long_name": "Ossona",
           "short_name": "Ossona",
           "types": [ "locality", "political" ]
         }, {
           "long_name": "Milan",
           "short_name": "MI",
           "types": [ "administrative_area_level_2", "political" ]
         }, {
           "long_name": "Lombardy",
           "short_name": "Lombardy",
           "types": [ "administrative_area_level_1", "political" ]
         }, {
           "long_name": "Italy",
           "short_name": "IT",
           "types": [ "country", "political" ]
         }, {
           "long_name": "20010",
           "short_name": "20010",
           "types": [ "postal_code" ]
         } ],
         "geometry": {
           "location": {
             "lat": 45.5074444,
             "lng": 8.9023200
           },
           "location_type": "GEOMETRIC_CENTER",
           "viewport": {
             "southwest": {
               "lat": 45.5043320,
               "lng": 8.8990670
             },
             "northeast": {
               "lat": 45.5106273,
               "lng": 8.9053622
             }
           },
           "bounds": {
             "southwest": {
               "lat": 45.5064427,
               "lng": 8.9020024
             },
             "northeast": {
               "lat": 45.5085166,
               "lng": 8.9024268
             }
           }
         }
       }
      ]
    }
  /.strip
  GOOGLE3_REVERSE_MADRID=%q/
  {
    "status": "OK",
    "results": [ {
      "types": [ ],
      "formatted_address": "Calle de las Carretas, 28013 Madrid, Spain",
      "address_components": [ {
        "long_name": "Calle de las Carretas",
        "short_name": "Calle de las Carretas",
        "types": [ "route" ]
      }, {
        "long_name": "Madrid",
        "short_name": "Madrid",
        "types": [ "locality", "political" ]
      }, {
        "long_name": "Madrid",
        "short_name": "M",
        "types": [ "administrative_area_level_2", "political" ]
      }, {
        "long_name": "Madrid",
        "short_name": "Madrid",
        "types": [ "administrative_area_level_1", "political" ]
      }, {
        "long_name": "Spain",
        "short_name": "ES",
        "types": [ "country", "political" ]
      }, {
        "long_name": "28013",
        "short_name": "28013",
        "types": [ "postal_code" ]
      } ],
      "geometry": {
        "location": {
          "lat": 40.4166824,
          "lng": -3.7033411
        },
        "location_type": "APPROXIMATE",
        "viewport": {
          "southwest": {
            "lat": 40.4135351,
            "lng": -3.7064880
          },
          "northeast": {
            "lat": 40.4198303,
            "lng": -3.7001927
          }
        },
        "bounds": {
          "southwest": {
            "lat": 40.4166419,
            "lng": -3.7033685
          },
          "northeast": {
            "lat": 40.4167235,
            "lng": -3.7033122
          }
        }
      }
    } ]
  }
  /
  GOOGLE3_COUNTRY_CODE_BIASED_RESULT=%q/
  {
    "status": "OK",
    "results": [ {
      "types": [ "administrative_area_level_2", "political" ],
      "formatted_address": "Syracuse, Italy",
      "address_components": [ {
        "long_name": "Syracuse",
        "short_name": "SR",
        "types": [ "administrative_area_level_2", "political" ]
      }, {
        "long_name": "Sicily",
        "short_name": "Sicily",
        "types": [ "administrative_area_level_1", "political" ]
      }, {
        "long_name": "Italy",
        "short_name": "IT",
        "types": [ "country", "political" ]
      } ],
      "geometry": {
        "location": {
          "lat": 37.0630218,
          "lng": 14.9856176
        },
        "location_type": "APPROXIMATE",
        "viewport": {
          "southwest": {
            "lat": 36.7775664,
            "lng": 14.4733800
          },
          "northeast": {
            "lat": 37.3474070,
            "lng": 15.4978552
          }
        },
        "bounds": {
          "southwest": {
            "lat": 36.6441736,
            "lng": 14.7724913
          },
          "northeast": {
            "lat": 37.4125978,
            "lng": 15.3367367
          }
        }
      }
    } ]
  }
  /
  GOOGLE3_TOO_MANY=%q/
    {
       "status": "OVER_QUERY_LIMIT"
    }
  /
  def setup
    super
    @google_full_hash = {:street_address=>"100 Spear St", :city=>"San Francisco", :state=>"CA", :zip=>"94105", :country_code=>"US"}
    @google_city_hash = {:city=>"San Francisco", :state=>"CA"}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)
  end  

  def test_google3_full_address
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE3_FULL)
    url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@address)}"
    Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder3.geocode(@address)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.7921509,-122.394", res.ll # slightly dif from yahoo
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
    assert_equal "google3", res.provider
  end
  
  def test_google3_full_address_with_geo_loc
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_FULL)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@full_address_short_zip)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.geocode(@google_full_loc)
     assert_equal "CA", res.state
     assert_equal "San Francisco", res.city 
     assert_equal "37.7921509,-122.394", res.ll # slightly dif from yahoo
     assert res.is_us?
     assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
     assert_equal "google3", res.provider
   end  
   
   def test_google3_full_address_accuracy
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_FULL)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@full_address_short_zip)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.geocode(@google_full_loc)
     assert_equal 9, res.accuracy
   end
  
   def test_google3_city
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_CITY)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@address)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.do_geocode(@address)
     assert_nil res.street_address
     assert_equal "CA", res.state
     assert_equal "San Francisco", res.city
     assert_equal "37.7749295,-122.4194155", res.ll
     assert res.is_us?
     assert_equal "San Francisco, CA, USA", res.full_address
     assert_equal "google3", res.provider
   end  
   
   def test_google3_city_accuracy
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_CITY)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@address)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.geocode(@address)
     assert_equal 4, res.accuracy
   end
   
   def test_google3_city_with_geo_loc
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_CITY)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@address)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.geocode(@google_city_loc)
     assert_equal "CA", res.state
     assert_equal "San Francisco", res.city
     assert_equal "37.7749295,-122.4194155", res.ll
     assert res.is_us?
     assert_equal "San Francisco, CA, USA", res.full_address
     assert_nil res.street_address
     assert_equal "google3", res.provider
   end  

   def test_google3_suggested_bounds
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_FULL)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@full_address_short_zip)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res = Geokit::Geocoders::GoogleGeocoder3.geocode(@google_full_loc)
     
     assert_instance_of Geokit::Bounds, res.suggested_bounds
     assert_equal Geokit::Bounds.new(Geokit::LatLng.new(37.7890033, -122.3971476), Geokit::LatLng.new(37.7952985, -122.3908524)), res.suggested_bounds
   end
   
   def test_service_unavailable
     response = MockFailure.new
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(@address)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     assert !Geokit::Geocoders::GoogleGeocoder3.geocode(@google_city_loc).success
   end 
   
   def test_multiple_results
     #Geokit::Geocoders::GoogleGeocoder3.do_geocode('via Sandro Pertini 8, Ossona, MI')
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_MULTI)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape('via Sandro Pertini 8, Ossona, MI')}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.geocode('via Sandro Pertini 8, Ossona, MI')
     assert_equal "Lombardy", res.state
     assert_equal "Mesero", res.city
     assert_equal "45.4966218,8.852694", res.ll
     assert !res.is_us?
     assert_equal "Via Sandro Pertini, 8, 20010 Mesero MI, Italy", res.full_address
     assert_equal "8 Via Sandro Pertini", res.street_address
     assert_equal "google3", res.provider
  
     assert_equal 2, res.all.size
     res = res.all[1]
     assert_equal "Lombardy", res.state
     assert_equal "Ossona", res.city
     assert_equal "45.5074444,8.90232", res.ll
     assert !res.is_us?
     assert_equal "Via Sandro Pertini, 20010 Ossona MI, Italy", res.full_address
     assert_equal "Via Sandro Pertini", res.street_address
     assert_equal "google3", res.provider
   end
  # 
   def test_reverse_geocode
     #Geokit::Geocoders::GoogleGeocoder3.do_reverse_geocode("40.4167413, -3.7032498")
     madrid = Geokit::GeoLoc.new
     madrid.lat, madrid.lng = "40.4167413", "-3.7032498"
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_REVERSE_MADRID)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&latlng=#{Geokit::Inflector::url_escape(madrid.ll)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).
       returns(response)
     res=Geokit::Geocoders::GoogleGeocoder3.do_reverse_geocode(madrid.ll)
  
     assert_equal madrid.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
     assert_equal madrid.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
     assert_equal "ES", res.country_code
     assert_equal "google3", res.provider
  
     assert_equal "Madrid", res.city
     assert_equal "Madrid", res.state
  
     assert_equal "Spain", res.country
     assert_equal "street", res.precision
     assert_equal true, res.success
  
     assert_equal "Calle de las Carretas, 28013 Madrid, Spain", res.full_address
     assert_equal "28013", res.zip
     assert_equal "Calle de las Carretas", res.street_address
   end  

   def test_country_code_biasing
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_COUNTRY_CODE_BIASED_RESULT)
     
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=Syracuse&region=it"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     biased_result = Geokit::Geocoders::GoogleGeocoder3.geocode('Syracuse', :bias => 'it')
     
     assert_equal 'IT', biased_result.country_code
     assert_equal 'Sicily', biased_result.state
   end
  
   def test_too_many_queries
     response = MockSuccess.new
     response.expects(:body).returns(GOOGLE3_TOO_MANY)
     url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
     Geokit::Geocoders::GoogleGeocoder3.expects(:call_geocoder_service).with(url).returns(response)
     assert_raise Geokit::TooManyQueriesError do
       res=Geokit::Geocoders::GoogleGeocoder3.geocode(@address)
     end
   end
end
