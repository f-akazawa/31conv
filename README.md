NetCDF Profile 3.1コンバートツール
======================
ARGOS通信フロートのDファイル（netCDF Profile2.3)を  
Argo User's Manual　Version2.31(2011年6月14日版）からVersion3.1（FIX日未定）へ変換するツール

 Matlab（R2014a）にて作成


 
使い方
------
### Matlabコマンドウインドウ上で ###
    >>conv31(name)

 パラメータに入力したファイルをVersion3.1形式にコンバートします  
 出力ファイル名（Dxxxxxxx_xxx_NEW.nc)  
 _ファイル上書き禁止モードで作っているので、コマンド実行前に出来上がりファイル(Dxxxxxxx_xxx_NEW.nc)があると実行時エラーになります_


パラメータの解説
----------------
 
    >>conv31(name)
 
+   `name` :
    変換実行するファイル名をパス付きで指定する
 
今後の予定(未実装な機能）
--------
+ エラーチェックの導入  
    Manual2.31ではFIRMWARE_VERSIONがあるが、JAMSTECが現在持っているProfileには存在しない等がある。

+ ARGOS通信の自動判別  
	netCDFデータファイル内,POSITIONING_SYSTEMの値がARGOSのファイルのみ変換対象

ライセンス
----------
 一応...  
Copyright &copy; 2014 JAMSTEC  
Distributed under the [MIT License][mit].  
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
