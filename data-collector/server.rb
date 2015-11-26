require 'sinatra'
require 'json'
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

set :port, 5012

set :allow_origin, :any

post '/capture-data' do
  begin
    cross_origin
    obj = JSON.parse(request.body.read)
    p obj
    File.open("data.json","a") do |f|
      obj['data'].each do |x|
        f.puts x.to_json
      end
    end
    {status: "success"}.to_json
  rescue Exception => e
    puts "#{e.message}: #{e.backtrace.join("\n")}"
  end
end
