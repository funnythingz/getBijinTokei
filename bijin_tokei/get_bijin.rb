#――――――――――――――――――――――――――――――
#  美人時計の画像を全取得するスクリプト
#  Author: hiroki ooiwa;
#

#------------------------------------------------------------
#  ライブラリのインポート
#
require 'net/http'
require 'uri'
require '/home/hiroki/dev_ruby/lib/ooiwa_frame_work'


#------------------------------------------------------------
#  初期設定ファイル
#
$scriptPath = '/home/hiroki/dev_ruby/bijin_tokei/'

#------------------------------------------------------------
#  美人時計から画像を取得
#
#  スクリプト参考元: Yamashiro0217さん
#  http://d.hatena.ne.jp/Yamashiro0217/20090930/1254305886
#
def getBijin()
	error_files = ""
	0..24.times do |hour|
	   0..60.times do |minute|
	      now_hour = sprintf("%0#{2}d", hour)
	      now_minute = sprintf("%0#{2}d", minute)
	      sleep 1
	      begin
	         Net::HTTP.start("bijint.com", 80) do |http|
	         response = http.get(
#	         	"/assets/pict/cc/590x450/#{now_hour}#{now_minute}.jpg",
	         	"/jp/tokei_images/#{now_hour}#{now_minute}.jpg",
	         	{"Referer" => "http://bijint.com/jp/" }
	         )
	         open( $scriptPath + getTimeNow(0) + '/' + "#{now_hour}#{now_minute}.jpg", "wb" ) do |file|
	             file.puts response.body
	         end
	      end
	      rescue 
	         p "#{now_hour}#{now_minute}.jpg can not get"
	         error_files += "http://bijint.com/jp/tokei_images/#{now_hour}#{now_minute}.jpg\n"
	      end
	   end
	end
end

#------------------------------------------------------------
#  初期実行関数
#
def init()
	if mkdir( $scriptPath + getTimeNow(0) )
		getBijin()
		p 'get bijin_tokei !'
	end
end

init()
