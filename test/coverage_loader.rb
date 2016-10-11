unless ENV['COVERAGE'] == 'off'
  COVERAGE_THRESHOLD = 96
  require 'simplecov'
  require 'simplecov-rcov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatters = [
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/test/'
    add_group 'lib', 'lib'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    puts "Coverage is #{'%.2f' % percent}%"
    unless percent >= COVERAGE_THRESHOLD
      puts "Coverage must be above #{COVERAGE_THRESHOLD}%"
      Kernel.exit(1)
    end
  end
end
