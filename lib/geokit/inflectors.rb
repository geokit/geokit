module Geokit
  module Inflector
    require 'cgi'

    extend self

    def titleize(word)
      humanize(underscore(word)).gsub(/\b([a-z])/u) { $1.capitalize }
    end

    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/u, '\1_\2').
        gsub(/([a-z\d])([A-Z])/u, '\1_\2').
        tr('-', '_').
        downcase
    end

    def humanize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/_id$/, '').gsub(/_/, ' ').capitalize
    end

    def url_escape(s)
      CGI.escape(s)
    end

    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
  end
end
