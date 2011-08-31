require File.expand_path('../config/load', __FILE__)

Sopserve.set(:environment => :production,
             :port        => ARGV.first || 8080,
             :logging     => true)

use Rack::AsyncStream
run Sopserve


