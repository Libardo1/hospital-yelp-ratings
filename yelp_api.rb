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
	parsed = JSON.parse(access_token.get(path).body)
	parsed["businesses"].each do |hosp|
		CSV.open("/Users/jsemer/Dropbox/yelp/test/" + zip + ".csv", "ab") do |csv|
		 	csv << [hosp['id'], 
				 	hosp['is_claimed'], 
				 	hosp['is_closed'], 
				 	hosp['name'], 
				 	hosp['review_count'], 
				 	hosp['categories'].shift.shift,
				 	hosp['rating'], 
				 	hosp['snippet_text'], 
				 	hosp['location']['address'][0],
				 	hosp['location']['address'][1],
				 	hosp['location']['city'],
				 	hosp['location']['state_code'], 
				 	hosp['location']['postal_code']]
		end
	end
end
