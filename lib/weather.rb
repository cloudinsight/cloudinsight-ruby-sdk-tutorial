#! /usr/bin/env ruby

require 'excon'
require 'json'
require 'oneapm_ci'

weather_res = Excon.get("http://d1.weather.com.cn/sk_2d/101011400.html?_=14420685#{rand(9999)}", 
  :headers => {'Referer' => 'http://m.weather.com.cn/mweather1d/101011400.shtml', 
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0'
  }
)

weather = JSON.parse($1) if weather_res.body =~ /=\s+(.*)/
puts "res : #{weather}"
puts "cityname : #{weather['cityname']}"

statsd = OneapmCi::Statsd.new

statsd.gauge("weather.temp_10", weather['temp'].to_f + 10.0, ['weather.oneapm'])
#statsd.gauge("weather.temp+11", weather['temp'].to_f + 10.0, ['weather.oneapm'])
statsd.gauge("weather.wse", weather['wse'].gsub('&lt;', '').gsub('&gt;', '').to_f, ['weather.oneapm'])
statsd.gauge("weather.sd", weather['SD'].to_f, ['weather.oneapm'])

