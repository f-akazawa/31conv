NetCDF Profile 3.1コンバートツール
======================
ARGOS通信フロートのDファイル（netCDF Profile2.3)を  
Argo User's Manual　Version2.31(2011年6月14日版）からVersion3.1（FIX日未定）へ変換するツール

 Matlab（R2014a）にて作成
 
使い方
------
### Matlabコマンドウインドウ上で ###
    >>31conv  
 _現在は入出力ファイルともにスクリプトに記述している_
 
パラメータの解説
----------------
今後パラメータを渡して大量に変換できるようにする。
 
    >>31conv(param1)
 
+   `param1` :
    入力ファイル名、もしくはディレクトリ名を指定する
 
今後の予定(未実装な機能）
--------
+ データベースからの読み取り（教えてもらったコード）

```c
logintimeout(5);  
conn=database('argo2012','argo','argo','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.16.201:1521:');
ex1=exec(conn,['select obs_mode from float_info,sensor_axis_info where sensor_axis_info.argo_id=float_info.argo_id  
and wmo_no='''wmo '''' ' and axis_no=1and param_id=1']);  
curs1=fetch(ex1);
close(conn);
ver_sam_sc=curs1.Data;
```

+ 入出力ファイルの固定化をやめる  
    入力ファイルの自動判定もできると良い（Dファイル、Rファイルとあるため、本ツールはDファイルのみ対象）
+ エラーチェックの導入  
    Manual2.31ではFIRMWARE_VERSIONがあるが、JAMSTECが現在持っているProfileには存在しない等
+ その他思いついたら書く

ライセンス
----------
 一応...  
Copyright &copy; 2014 JAMSTEC  
Distributed under the [MIT License][mit].  
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
