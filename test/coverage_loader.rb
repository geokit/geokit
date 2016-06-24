unless ENV["COVERAGE"] == 'off'
  COVERAGE_THRESHOLD = 95
  require "simplecov"
  require "simplecov-rcov"
  require "coveralls"
  Coveralls.wear!

  SimpleCov.formatters = [
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter "/test/"
    add_group "lib", "lib"
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    unless percent >= COVERAGE_THRESHOLD
      puts "Coverage must be above #{COVERAGE_THRESHOLD}%. It is #{'%.2f' % percent}%"
      Kernel.exit(1)
    end
  end
end
