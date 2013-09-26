#============================================================
# マスターファイルを圧縮し、
# 定期的にマスターをバックアップするスクリプト
#============================================================

#------------------------------------------------------------
# ライブラリのインポート
#
require '/home/hiroki/dev_ruby/lib/ooiwa_frame_work'

#------------------------------------------------------------
# 環境設定
#
$projDir = '/bijin_tokei/'

$scriptPath = '/home/hiroki/dev_ruby' + $projDir
$masterDirName = '_master'
$masterDirPath = $scriptPath + $masterDirName

#------------------------------------------------------------
# 公開先
#
$putPath = '/home/hiroki/bijin_htdocs/bijin_tokei/_master/'
$putDir = $putPath + $masterDirName

#------------------------------------------------------------
# メール設定
#
$mail_address_to = 'bijin_bot@funnythingz.com'


#------------------------------------------------------------
# main関数を定義
#
def main()
	@total_array = []
	@put_name = $putDir + '_' + getTimeNow(0) + '_bijin.zip'
	
	@masterList = Dir.entries( $masterDirPath ).sort()
	@masterList.each do |val|
		unless val == '.' || val == '..'
			@total_array.push( $masterDirPath + '/' + val )
		end
	end
	
	# 全画像を圧縮して、公開ディレクトリへ移動
	if ruby_zip( @total_array, @put_name )
		FileUtils.chmod( 0755, @put_name )
		p 'zip sucess!'
		
		#------------------------------------------------------------
		# 公開ファイルをメールで連絡
		#
		
		# メール送信内容を設定
		mail_address_from = 'bijin_bot@funnythingz.com'
		mail_subject = '[bijin_tokei] master_' + getTimeNow(0);
		mail_to_url = 'Download is ' + 'http://bijin.funnythingz.com' + $projDir + $masterDirName + '/' + $masterDirName + '_' + getTimeNow(0) + '_bijin.zip'
		mail_basic = "\n\n" + 'id: bijin_bot' + "\n" + 'pass: get_bijin_315'
		mail_string = mail_subject + "\n\n" + mail_to_url + mail_basic
		
		# メール送信
		mail( mail_subject, mail_string, $mail_address_to, mail_address_from )
		p 'sucesseeeed!!'
	else
		p 'falsed!!'
	end
end

#------------------------------------------------------------
# 実行
#
main()
