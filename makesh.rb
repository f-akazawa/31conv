## ARGOS通信のあるWMO番号リストをDBから作ってもらったので
## 自作のプロファイル3.1変換スクリプトを実行するファイルのリストを作成するためのツール
## おそらく一度しか使わないはず
## 全DファイルRファイルのリストはシェルスクリプト（filelist.sh)にて抜き出し
## Rファイルは変換対象外なので、sedコマンドでざっくり削除。
## 変換対象のARGOS通信フロートリストはlist_wmo_argos_d.txtにあるので、マッチした部分を吐き出してシェルスクリプトにする

def readfile

wmolist = File.open('list_wmo_argos_d.txt','r') # 変換対象リストの読み込み

# 1行毎になっているので、配列に入れる。
wmo_list_array = Array.new

        wmolist.eachline{|line|
                wmo_list_array.push line
                print line
        }
wmolist.close

