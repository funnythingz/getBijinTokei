#――――――――――――――――――――――――――――――
#  美人時計の画像を日付ごとに比較して差分を抽出する
#  Author: hiroki ooiwa;
#

#------------------------------------------------------------
#  ライブラリのインポート
#
require 'digest/md5'
require '/home/hiroki/dev_ruby/lib/ooiwa_frame_work'

#------------------------------------------------------------
#  全体の設定
#

# 環境設定
$projDir = '/bijin_tokei/'
$scriptPath = '/home/hiroki/dev_ruby' + $projDir

$targetDir = getTimeNow(0)
#$targetDir = '20100901'


$todayDir = $scriptPath + $targetDir


#公開先
$putPath = '/home/hiroki/bijin_htdocs/bijin_tokei/'
$putDir = $putPath + $targetDir

# メール設定
$mail_address_to = 'bijin_bot@funnythingz.com'

#------------------------------------------------------------
#  前日と当日を比較するための関数
#
def hikaku( before, after )

	#------------------------------------------------------------
	#  前日の画像フォルダと、当日の画像フォルダから、
	#  画像リストを配列に代入
	#
	beforeList = Dir::entries( before ).to_s.gsub('...'){''}.gsub( /g([0-9])/ ){ 'g ' + $1 }.split(' ').sort()
	
	diffList = []
	
	beforeList.each do |val|
		if File.exists?( after + val )
			rb = Digest::MD5.hexdigest( File.open( before + val, 'rb' ).read )
			ra = Digest::MD5.hexdigest( File.open( after + val, 'rb' ).read )

			if rb === ra
				# 処理なし
			else
				FileUtils.cp( after + val, $todayDir + '_diff/' + val )
				diffList.push( val )
			end
		else
			p 'Not Found "' + after + val + '"'
		end
	end
	# 差分リストの書き出し
	if put_list( diffList, $scriptPath + 'log/' + $targetDir + '_list.txt' )
		print '美人時計の差分ファイルログを"' + $targetDir + '_list.txt"' + 'に書き出しました。'
		print "\n"
		return true;
	end
end


#------------------------------------------------------------
#  初期実行関数
#
def init()
	@cacheDir = $scriptPath + '_cache'
	@masterDir = $scriptPath + '_master'
	@total_val = ''
	@total_array = []
	
	unless File.exists?( @cacheDir )
		FileUtils.cp_r( @masterDir, @cacheDir )
		if mkdir( $todayDir + '_diff' )
		
			# 前日のフォルダと本日のフォルダの差分ファイルを比較し、
			# 差分を抽出する。
			if hikaku( @cacheDir + '/', $todayDir + '/' )
				# 差分抽出後、本日のフォルダは削除し、
				# 差分を抽出したフォルダを本日のフォルダにリネームする。
				while File.exists?( $todayDir + '_diff' )
					killDir( $todayDir )
					until File.exists?( $todayDir )
						File::rename( $todayDir + '_diff', $todayDir )
					end
					
					# キャッシュフォルダを削除
					killDir( @cacheDir )
					
					# 差分をマスターフォルダに上書きし、次回差分比較に備える
					@beforeList = Dir.entries( $todayDir ).sort()
					@beforeList.each do |val|
						unless val == '.' || val == '..'
							@total_val += val + ' , '
							@total_array.push( $todayDir + '/' + val )
							FileUtils.cp_r( $todayDir + '/' + val, @masterDir )
						end
					end
					if @total_val != ''
						#twit( 'てすつ投稿やねん' )
						
						#------------------------------------------------------------
						# 差分を固めて公開ディレクトリへ移動
						#
						if ruby_zip( @total_array, $putDir + '_bijin.zip' )
							p 'zip sucess!'
							FileUtils.chmod( 0755, $putDir + '_bijin.zip' )
						end
						
						#------------------------------------------------------------
						# 差分結果をメールで報告
						#
=begin
						mail_address_from = 'bijin_bot@funnythingz.com'
						mail_subject = '[bijin_tokei] ' + $targetDir
						mail_to_url = "\n\n" + 'Download is ' + 'http://bijin.funnythingz.com' + $projDir + $targetDir + '_bijin.zip'
						mail_basic = "\n\n" + 'id: bijin_bot' + "\n" + 'pass: get_bijin_315'
						mail_string = mail_subject + "\n\n" + @total_val + mail_to_url + mail_basic
						
						mail( mail_subject, mail_string, $mail_address_to, mail_address_from )
						
						p 'sucesseeeed!!'
=end
						
						#------------------------------------------------------------
					else
						p 'no image'
					end
				end
			end
		end
	end
end

init()
