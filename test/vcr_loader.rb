require 'vcr'

VCR.configure do |c|
  c.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  # Yahoo BOSS Ignore changing params
  c.default_cassette_options = {
    match_requests_on: [
      :method,
      VCR.request_matchers.uri_without_params(
        :oauth_nonce, :oauth_timestamp, :oauth_signature
      )
    ]
  }
end
