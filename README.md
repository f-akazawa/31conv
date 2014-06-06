NetCDF Profile 3.1コンバートツール
======================
ARGOS通信フロートのDファイル（netCDF Profile2.3)を  
Argo User's Manual　Version2.31(2011年6月14日版）からVersion3.1（FIX日未定）へ変換するツール

 Matlab（R2014a）にて作成


 
使い方
------
### Matlabコマンドウインドウ上で ###
    >>conv31(filename)

 引数で入力したファイルをVersion3.1形式にコンバートします  
 出力ファイル名（newDxxxxxxx_xxx.nc)  
 _ファイル上書き禁止モードで作っているので、コマンド実行前に出来上がりファイル(newDxxxxxxx_xxx.nc)があると実行時エラーになります_

パラメータの解説
----------------
 
    >>conv31(filename)
 
+   `filename` :
    変換実行するファイル名
 
今後の予定(未実装な機能）
--------
+ 出力ファイルの固定化をやめる  
    もしかしたら不必要かもしれない。

+ エラーチェックの導入  
    Manual2.31ではFIRMWARE_VERSIONがあるが、JAMSTECが現在持っているProfileには存在しない等がある。

+ 他・・・

ライセンス
----------
 一応...  
Copyright &copy; 2014 JAMSTEC  
Distributed under the [MIT License][mit].  
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
