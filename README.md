NetCDF Profile 3.1コンバートツール
======================
ARGOS通信フロートのDファイル（netCDF Profile2.3)を  
Argo User's Manual　Version2.31(2011年6月14日版）からVersion3.1（FIX日未定）へ変換するツール

 Matlab（R2014a）にて作成


 
使い方
------
### Matlabコマンドウインドウ上で ###
    >>tooltest  
 _現在は入出力ファイルともにスクリプトに記述している_
 _今後スクリプトのファイル名を31convに変更_
 _ファイル上書き禁止モードで作っているので、コマンド実行前にupdatefile.ncがあると実行エラーになります_


パラメータの解説(予定）
----------------
今後パラメータを渡して大量に変換できるようにする。
 
    >>tooltest(param1)
 
+   `param1` :
    入力ファイル名、もしくはディレクトリ名を指定する
 
今後の予定(未実装な機能）
--------
+ 入出力ファイルの固定化をやめる  
    入力ファイルの自動判定もできると良い（Dファイル、Rファイルとあるため、本ツールはDファイルのみ対象）

+ エラーチェックの導入  
    Manual2.31ではFIRMWARE_VERSIONがあるが、JAMSTECが現在持っているProfileには存在しない等がある。

+ 他・・・

ライセンス
----------
 一応...  
Copyright &copy; 2014 JAMSTEC  
Distributed under the [MIT License][mit].  
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
