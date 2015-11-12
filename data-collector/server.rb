require 'sinatra'
require 'json'
require 'sinatra/cross_origin'

set :port, 5012

# options '/*' do
#     response["Access-Control-Allow-Headers"] = "origin, x-requested-with, content-type"
# end
configure do
  enable :cross_origin
end

post '/capture-data' do
  puts "hi!"
  cross_origin
  obj = JSON.parse(request.body.read)
  p obj
  File.open("data.json","a") do |f|
    obj['data'].each do |x|
      f.puts x.to_json
    end
  end
  {status: "success"}.to_json
end
