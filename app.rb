require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "mecab"
require "natto"
require "pry"

get "/" do
  erb :index
end

post "/complete" do
  @text = params[:text]
  
  natto = Natto::MeCab.new
  nattos = []

  natto.parse(@text) do |n|
    nattos << n.surface
  end

  @results = {}

  nattos.uniq.each do |surface|
    @results[surface] = nattos.count(surface)
  end

#   @outputs = []

#  results.keys.each do |key|
#    @outputs << key + " => " + results[key].to_s
#  end

  erb :complete
end
