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

def raise_error_when_empty
  if @text.empty?
    flash[:notice] = "テキストを入力してください。"
    redirect "/"
  end
end

def mecab_freq(text)
  mecab = MeCab::Tagger.new
  node = mecab.parseToNode(text)
  noun_array = []
  
  begin
    node = node.next
    if /^#{@wordclass}/ =~ node.feature.force_encoding("UTF-8")
      noun_array << node.surface.force_encoding("UTF-8")
    end
  end until node.next.feature.include?("BOS/EOS")

  uniq_noun_array = noun_array.uniq

  word_and_count = {}

  uniq_noun_array.each do |noun|
    word_and_count[noun] = noun_array.count(noun)
  end

  @word_and_count = Hash[ word_and_count.sort_by{ |_, v| -v } ]

end

get "/" do
  erb :index
end

post "/freq" do
  @text = params[:freq][:content]
  wordclass = params[:freq][:wordclass]
  @wordclass = wordclass == "未選択" ? nil : wordclass

  raise_error_when_empty


  mecab_freq(@text)
  
  erb :freq
end

post "/cooccur" do
  @word = params[:cooc][:word]
  @text = params[:cooc][:base]
  wordclass = params[:cooc][:wordclass]
  @wordclass = wordclass == "未選択" ? nil : wordclass
  raise_error_when_empty
  
  trials = @text.length / 60
  puts trials
  where_to_split_from = [0, 20, 40]
  @word_and_logs = {}
  
  where_to_split_from.each do |split| # 60字ごとの区切り位置を3回調整することで精度向上
    for trial in 1..trials do # 60字ごとに区切る
      puts trial
      first_char_index = ( trial - 1 ) * 60 + 1 * split
      last_char_index  = trial * 60 + split
      @text.slice!(first_char_index, last_char_index)
      
      if @text.include?(@word)
        
        mecab_freq(@text)
        freq_words = @word_and_count.keys
        
        freq_words.each do |key| 
          @word_and_count[key] = Math.log(@word_and_count[key])
        end 
        
        @word_and_logs.merge!(@word_and_count) do | key, existingval, newval |
          @word_and_logs.keys.include?(freq_words) ? existingval + newval : newval
        end
      end
      
    end
  end

  @word_and_logs = 
    Hash[ @word_and_logs.sort_by{ |_, v| -v } ].delete_if{ |key, val| 
      val == 0 || key.include?(@word) }

  erb :cooccur
end
