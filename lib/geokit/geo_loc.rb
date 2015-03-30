module Geokit
  # This class encapsulates the result of a geocoding call.
  # It's primary purpose is to homogenize the results of multiple
  # geocoding providers. It also provides some additional functionality, such as
  # the "full address" method for geocoders that do not provide a
  # full address in their results (for example, Yahoo), and the "is_us" method.
  #
  # Some geocoders can return multple results. Geoloc can capture multiple
  # results through its "all" method.
  #
  # For the geocoder setting the results, it would look something like this:
  #     geo=GeoLoc.new(first_result)
  #     geo.all.push(second_result)
  #     geo.all.push(third_result)
  #
  # Then, for the user of the result:
  #
  #     puts geo.full_address     # just like usual
  #     puts geo.all.size  => 3   # there's three results total
  #     puts geo.all.first        # all is just an array or additional geolocs,
  #                                 so do what you want with it
  class GeoLoc < LatLng
    # Location attributes. Full address is a concatenation of all values.
    # For example:
    # 100 Spear St, San Francisco, CA, 94101, US
    # Street number and street name are extracted from the street address
    # attribute if they don't exist
    attr_accessor :street_number, :street_name, :street_address, :city, :state,
                  :state_name, :state_code, :zip, :country_code, :country
    attr_accessor :full_address, :all, :district, :province, :sub_premise,
                  :neighborhood
    # Attributes set upon return from geocoding. Success will be true for
    # successful geocode lookups. The provider will be set to the name of the
    # providing geocoder. Finally, precision is an indicator of the accuracy of
    # the geocoding.
    attr_accessor :success, :provider, :precision, :suggested_bounds
    # accuracy is set for Yahoo and Google geocoders, it is a numeric value of
    # the precision. see
    # http://code.google.com/apis/maps/documentation/geocoding/#GeocodingAccuracy
    attr_accessor :accuracy
    # FCC Attributes
    attr_accessor :district_fips, :state_fips, :block_fips

    # Constructor expects a hash of symbols to correspond with attributes.
    def initialize(h = {})
      @all = [self]

      @street_address = h[:street_address]
      @sub_premise = nil
      @street_number = nil
      @street_name = nil
      @city = h[:city]
      @state = h[:state]
      @state_code = h[:state_code]
      @state_name = h[:state_name]
      @zip = h[:zip]
      @country_code = h[:country_code]
      @province = h[:province]
      @success = false
      @precision = 'unknown'
      @full_address = nil
      super(h[:lat], h[:lng])
    end

    def state
      @state || @state_code || @state_name
    end

    # Returns true if geocoded to the United States.
    def is_us?
      country_code == 'US'
    end

    def success?
      success == true
    end

    # full_address is provided by google but not by yahoo. It is intended that
    # the google geocoding method will provide the full address, whereas for
    # yahoo it will be derived from the parts of the address we do have.
    def full_address
      @full_address ? @full_address : to_geocodeable_s
    end

    # Extracts the street number from the street address where possible.
    def street_number
      @street_number ||= street_address[/(\d*)/] if street_address
      @street_number
    end

    # Returns the street name portion of the street address where possible
    def street_name
      @street_name ||= street_address[street_number.length, street_address.length].strip if street_address
      @street_name
    end

    # gives you all the important fields as key-value pairs
    def hash
      res = {}
      fields = [:success, :lat, :lng, :country_code, :city, :state, :zip,
       :street_address, :province, :district, :provider, :full_address, :is_us?,
       :ll, :precision, :district_fips, :state_fips, :block_fips, :sub_premise]
      fields.each { |s| res[s] = send(s.to_s) }
      res
    end
    alias to_hash hash

    # Sets the city after capitalizing each word within the city name.
    def city=(city)
      @city = Geokit::Inflector.titleize(city) if city
    end

    # Sets the street address after capitalizing each word within the street
    # address.
    def street_address=(address)
      @street_address = if address && provider != 'google'
        Geokit::Inflector.titleize(address)
      else
        address
      end
    end

    # Returns a comma-delimited string consisting of the street address, city,
    # state, zip, and country code.  Only includes those attributes that are
    # non-blank.
    def to_geocodeable_s
      a = [street_address, district, city, province, state, zip, country_code].compact
      a.delete_if { |e| !e || e == '' }
      a.join(', ')
    end

    def to_yaml_properties
      (instance_variables - ['@all', :@all]).sort
    end

    def encode_with(coder)
      to_yaml_properties.each do |name|
        coder[name[1..-1].to_s] = instance_variable_get(name.to_s)
      end
    end

    # Returns a string representation of the instance.
    def to_s
      ["Provider: #{provider}",
       "Street: #{street_address}",
       "City: #{city}",
       "State: #{state}",
       "Zip: #{zip}",
       "Latitude: #{lat}",
       "Longitude: #{lng}",
       "Country: #{country_code}",
       "Success: #{success}"
      ].join("\n")
    end
  end
end
