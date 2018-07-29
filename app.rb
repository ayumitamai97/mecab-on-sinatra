require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "sinatra/form_helpers"
require "mecab"
require "pry"
require "sinatra/asset_pipeline/task"
require "sass"
require 'sass/plugin/rack'
require "rack-flash"
require "rack/flash/test"

use Rack::Flash

get "/" do
  erb :index
end

post "/complete" do
  @text = params[:text][:content]
  
  if @text.empty?
    flash[:hoge] = "テキストを入力してください。"
    redirect "/"
  end

  wordclass = params[:text][:wordclass]
  @wordclass = wordclass == "未選択" ? nil : wordclass

  mecab = MeCab::Tagger.new
  node = mecab.parseToNode(@text)
  @noun_array = []

  begin
    node = node.next
    if /^#{@wordclass}/ =~ node.feature.force_encoding("UTF-8")
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
