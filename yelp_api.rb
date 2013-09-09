require 'rubygems'
require 'oauth'
require	'csv'
require 'json'

consumer_key = ''
consumer_secret = ''
token = ''
token_secret = ''

api_host = 'api.yelp.com'

consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
access_token = OAuth::AccessToken.new(consumer, token, token_secret)

zip = []
path = []
for i in 0..2652 do
	zip = CSV.read('/Users/jsemer/Dropbox/yelp/ca_zip.csv')[i][0]
	path = "/v2/search?location=" + zip + "&category_filter=hospitals"
	File.open("/Users/jsemer/Dropbox/yelp/" + zip + ".json","w") do |f| 
		f.write(access_token.get(path).body.to_json)
	end
end
