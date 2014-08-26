#!/usr/local/bin/ruby
# -*- coding: utf-8-with-signature -*-

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

	fulllist.each_line{|line2|
		full_array.push line2
	}
fulllist.close

# マッチした行を確認して新たなファイルに書き出す
out = File.open("out.sh","w")
for wmo_no in wmo_list_array do
reg = Regexp.new("#{wmo_no}".chomp!)
# p wmo_no
  	for var in full_array do
          str2 = "#{var}"
          # match_wmo : ARGOS通信のフロートWMO番号
          # var : 全Dファイルのフルパス、matlabコマンド実行スクリプト
          # 両者を比較してマッチしたvarを新しいファイルに書き出す。
          # 配列には改行付きで入っていたので削る必要あり
          # るーぷの要素も式展開をしないとぱたーんまっちでは使えない
          # 以上の点に非常にはまってしまった。
          if reg =~ str2 then
            # マッチしたら書き出し
            out.write(str2)
            else
          end
	end
end
out.close

