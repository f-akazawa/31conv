#!/usr/local/bin/ruby

## ARGOS通信のあるWMO番号リストをDBから作ってもらったので
## 自作のプロファイル3.1変換スクリプトを実行するファイルのリストを作成するためのツール
## おそらく一度しか使わないはず
## 全DファイルRファイルのリストはシェルスクリプト（filelist.sh)にて抜き出し
## Rファイルは変換対象外なので、sedコマンドでざっくり削除。
## 変換対象のARGOS通信フロートリストはlist_wmo_argos_d.txtにあるので、マッチした部分を吐き出してシェルスクリプトにする


wmolist = File.open("list_wmo_argos_d.txt","r") # 変換対象リストの読み込み

# 1行毎になっているので、配列に入れる。
wmo_list_array = Array.new

        wmolist.each_line{|line|
                wmo_list_array.push line
        }
wmolist.close

# 全Dファイルのリストを読み込み
fulllist = File.open("convall.sh","r")

# 配列に保存
full_array = Array.new

	fulllist.each_line{|line|
		full_array.push line
	}
fulllist.close

# マッチした行を確認して新たなファイルに書き出す
out = File.open("out.sh","w")
hoge = 0
for match_wmo in wmo_list_array do
	for var in full_array do
		# match_wmo : ARGOS通信のフロートWMO番号
		# var : 全Dファイルのフルパス、matlabコマンド実行スクリプト
		# 両者を比較してマッチしたvarを新しいファイルに書き出す。
		if var.to_s.include?(match_wmo.to_s) then
		# マッチしない・・・なぜ？
			#out.write(var.to_s)
			hoge = hoge +1
		end
	end
	puts hoge 
end
out.close

