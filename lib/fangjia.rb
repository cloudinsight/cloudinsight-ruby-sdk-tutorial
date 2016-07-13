#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'cloudinsight-sdk'
require 'pry'
require_relative 'time_formater'

fangjia_page = Nokogiri::HTML(open('http://bj.lianjia.com/fangjia'))
  
areas = [
  '', 'dongcheng', 'xicheng', 'chaoyang', 'haidian', 'fengtai', 'shijingshan', 'tongzhou', 'changping', 'daxing', 
  'yizhuangkaifaqu', 'shunyi', 'fangshan', 'mentougou', 'pinggu', 'huairou', 'miyun', 'yanqing', 'yanjiao'
]

threads = []

areas.each do |area|
  threads << Thread.new do
    css = {}
    statsd = CloudInsight::Statsd.new
    url = "http://bj.lianjia.com/fangjia/#{area}"
    puts url
    area_fangjia_page = Nokogiri::HTML(open(url))
    if area.empty? # city special
      css[:saled] = 'div.g-main > div.m-tongji > div > div.box-l > div.box-l-b > div:nth-child(2) > div.num > span:nth-child(1)'
      css[:visited] = 'body > div.g-main > div.m-tongji > div > div.box-l > div.box-l-b > div:nth-child(3) > div.num > span:nth-child(1)'
      css[:kefang_yesterday] = 'div.g-main > div.m-tongji > div > div.box-l > div.box-l-b > div:nth-child(1) > div.num > span:nth-child(1)'
    end
    fangjia = search_info area_fangjia_page, css
    fangjia.each do |name, info|
      next if info.nil? || info.empty?
      area = area.empty? ? 'beijing' : area
      puts "#{TimeFormater.now} area:#{area} #{name}:#{info}"
      statsd.gauge("bj.fangjia.#{area}.#{name}", info)
    end
  end
end

def search_info(page, css = {})
  {}.tap do |fangjia|
    fangjia[:price] = page.css('#monthTrans').text # 均价 元/平米

    origin_fangyuan_info = page.css('div.g-main > div.m-tongji > div > div.box-l > div.box-l-t > div.qushi > div.qushi-2 > span:nth-child(4) > a:nth-child(1)').text
    fangyuan_info = /在售房源(?<num>.*)套/.match(origin_fangyuan_info)
    puts "WARNING origin_fangyuan_info: #{origin_fangyuan_info}" unless fangyuan_info
    fangjia[:fangyuan] = fangyuan_info && fangyuan_info[:num] # 在售房源

    origin_saled_info = page.css('div.g-main > div.m-tongji > div > div.box-l > div.box-l-t > div.qushi > div.qushi-2 > span:nth-child(4) > a:nth-child(2)').text
    saled_in_90_days_info = /成交房源(?<num>.*)套/.match(origin_saled_info)
    puts "WARNING saled_in_90_days_info: #{origin_saled_info}" unless saled_in_90_days_info
    fangjia[:saled_in_90_days] = saled_in_90_days_info && saled_in_90_days_info[:num] # 最近90天内成交房源

    fangjia[:kefang_yesterday] = page.css(css[:kefang_yesterday] ).text if css[:kefang_yesterday] # 昨日新增客房比-城市范围

    saled_css = css[:saled] ? css[:saled] : 'div.g-main > div.m-tongji > div > div.box-l > div.box-l-b > div:nth-child(1) > div.num > span:nth-child(1)'
    fangjia[:saled_yesterday] = page.css(saled_css).text # 昨日成交量/套

    visited_css = css[:visited] ? css[:visited] : 'div.g-main > div.m-tongji > div > div.box-l > div.box-l-b > div:nth-child(2) > div.num > span:nth-child(1)'
    fangjia[:visited_yesterday] = page.css(visited_css).text # 昨日房源带看量/次
  end
end

threads.each(&:join)
