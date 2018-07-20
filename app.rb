require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "mecab"
require "pry"

get "/" do
  erb :index
end

post "/complete" do
  @text = params[:text]
  
  tagger = MeCab::Tagger.new
  words_arr = []


  mecab = MeCab::Tagger.new
  node = mecab.parseToNode(@text)
  @word_array = []

  begin
    node = node.next
    if /^名詞/ =~ node.feature.force_encoding("UTF-8")
      @word_array << node.surface.force_encoding("UTF-8")
    end
  end until node.next.feature.include?("BOS/EOS")

  erb :complete
end
