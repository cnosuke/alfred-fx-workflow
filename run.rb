# encoding: utf-8
require 'rest-client'
require 'json'
require 'time'

MAX_PLACEHOLDER = Time.now + (60*60*24*7)
CACHE_TTL = 20
YFX_URL = 'http://info.finance.yahoo.co.jp/fx/async/getRate/'

def match?(word, query)
  return false unless word
  word.match(/#{query}/i)
end

def rate_to_s(state, pair)
  result_str = state.map{|k,v| "#{k}: #{v}" }.join(",\t")
  "[#{pair.scan(/\w{3}/).join('/')}] #{result_str}"
end

def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg].encode(xml: :text)}" uid="#{options[:uid]}">
    <title>#{options[:title].encode(xml: :text)}</title>
    <subtitle>#{options[:subtitle].encode(xml: :text)}</subtitle>
    <icon>#{options[:icon]}</icon>
  </item>
  ITEM
end

cache_filename = "./cache/#{Time.now.to_i/CACHE_TTL}.json"
unless File.exist?(cache_filename)
  File.unlink *Dir.glob("./cache/*.json")
  open(cache_filename, 'w'){|io| io.puts (RestClient.post(YFX_URL, nil) || '{}') }
end

matches = JSON.parse(open(cache_filename, external_encoding: 'UTF-8').read)

queries = ARGV.
            first.
            dup.
            force_encoding('UTF-8').
            split(' ').
            map{|e| e.gsub('/','').gsub(/\s/,'') }.
            map{|e| Regexp.escape(e) }

queries = %w(JPY) if queries.size == 0

queries.each do |query|
  matches = matches.select do |k,v|
      match?(k, query)
  end
end


matches = [{'name' => '(nothing...)'}] if matches.size == 0

items = matches.map do |pair, val|
  title = "[#{pair.scan(/\w{3}/).join('/')}] Bid: #{val['Bid']}, Ask: #{val['Ask']}"
  sub = "Change: #{val['Change']}, Open: #{val['Open']}, High: #{val['High']}, Low: #{val['Low']}"

  item_xml({
    arg: title,
    uid: 0,
    icon: '168CA675-5F85-4A9E-A871-5B3871DD0EAC.png',
    title: title,
    subtitle: sub,
  })
end.join

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
