require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "sinatra/asset_pipeline/task"
require "sinatra/static_assets"
require "mecab"
require "pry"

get "/" do
  erb :index
end

post "/complete" do
  @text = params[:text]
  
  tagger = MeCab::Tagger.new

  mecab = MeCab::Tagger.new
  node = mecab.parseToNode(@text)
  @noun_array = []

  begin
    node = node.next
    if /^名詞/ =~ node.feature.force_encoding("UTF-8")
      @noun_array << node.surface.force_encoding("UTF-8")
    end
  end until node.next.feature.include?("BOS/EOS")

  @noun_array_uniq = @noun_array.uniq

  @noun_and_count = {}

  @noun_array_uniq.each do |noun|
    @noun_and_count[noun] = @noun_array.count(noun)
  end

  erb :complete
end
