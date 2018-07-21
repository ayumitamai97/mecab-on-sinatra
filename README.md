# つまづいた点の備忘録([ref](https://ja.stackoverflow.com/questions/46625/mecab%E3%82%92%E7%94%A8%E3%81%84%E3%81%9Fsinatra%E3%82%A2%E3%83%97%E3%83%AA%E3%82%92heroku%E3%81%AB%E3%83%87%E3%83%97%E3%83%AD%E3%82%A4%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95%E3%82%92%E3%81%94%E6%95%99%E7%A4%BA%E3%81%8F%E3%81%A0%E3%81%95%E3%81%84))

- nattoはHerokuで使えなさそう
  - nattoをrequireした行でエラーが出た。gemのインストールはできている。
- [Procfile](http://b0npu.hatenablog.com/entry/2016/12/28/210840)を作らないといけない
- Gemのインストール先を`vendor/bundle`に指定しないといけない
- (`$ heroku create -a heroku_app_name --buildpack https://github.com/diasks2/heroku-buildpack-mecab.git`←`--buildpack`というオプションをつけることで、`heroku create`時にビルドパックを指定できる)
- 一番重要：`$ heroku config:set LD_LIBRARY_PATH=/app/vendor/mecab/lib`を実行する
  - が、この環境変数が指定するパスがなんなのか分かっていないし調べ方が分からない（だからこそ重要そう？？）
  - ちなみに  
  ```
  $ gem which mecab 
  /app/vendor/bundle/ruby/2.4.0/gems/mecab-0.996/lib/mecab.so
  ```
  - また、
  ```
  $ ls /app/vendor/mecab/lib
  libmecab.a  libmecab.la  libmecab.so  libmecab.so.2  libmecab.so.2.0.0	mecab
  ```
  むむ。。
