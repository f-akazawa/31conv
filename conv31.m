function conv31(filename)

% 作業ディレクトリの場所、tempfile.ncはここに作る
workpath = '/home/argo/akazawa/';

% 引数からファイルパス、ファイル名を抜き出し
% pathstr pathの部分
% name 拡張子を除いたファイル名部分
% ext 拡張子
[pathstr,name,ext]=fileparts(filename);

% pathstrの後ろに区切りスラッシュを入れる
% origpath = strcat(pathstr,'/');

% 中間ファイルを作る
% 見た目の順番が違うだけなのでmachine readableとしてはこのファイルでも良い
tempfile = 'tempfile.nc';

% nameの先頭がRファイルだったら変換対象外なのでプログラム終了する
if strncmpi(name,'R',1) == 1
    exit(1);
end


% 最終出力ファイル名を作る (元ファイル_NEW.nc)
updatefile = strcat(name,'_NEW',ext);

% DBから読むのに必要なWMO番号をファイル名から抜き出す。（Dファイルのみ変換対象）
wmo_no = strsplit(name,{'D','_'},'CollapseDelimiters',true);
wmo = wmo_no{2};

% 出力ファイルのディレクトリ(作業ディレクトリにWMO番号で作成）
% 作成はシェルスクリプトでやる予定・・・
% outpath = strcat(workpath,wmo,'/');


% 以下から処理本体部分
% ファイルポインタ取得
finfo = ncinfo(filename);

% netcdf 読み込み
% dimensions
for i1=1:size(finfo.Dimensions,2)
    eval([finfo.Dimensions(i1).Name '=finfo.Dimensions(i1).Length;']);
end

% valiables
for i1=1:size(finfo.Variables,2)
    eval([finfo.Variables(i1).Name '=ncread([filename],finfo.Variables(i1).Name);']);
end

% 読み込んだので書きだす
% INST_REFERENCEは削除された変数なので、そこだけは書かないようにして書きだす

ncid1 = netcdf.create([workpath tempfile],'NC_CLOBBER');
for i1=1:size(finfo.Dimensions,2)
    if strcmp(finfo.Dimensions(i1).Name,'N_HISTORY') == 0
        netcdf.defDim(ncid1,finfo.Dimensions(i1).Name,finfo.Dimensions(i1).Length);
    end
end
netcdf.defDim(ncid1,'N_HISTORY',netcdf.getConstant('NC_UNLIMITED'));
netcdf.close(ncid1);


% Variables INST_REFERENCEだったらそこは書かない。（削除された変数なので）
% write netcdf contents

for i1=1:size(finfo.Variables,2)

    % variables
    ex1='';
    for i2=1:size(finfo.Variables(i1).Dimensions,2)
        ex1=[ex1 '''' finfo.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex1=ex1(1:end-1);
    
    if strcmp(finfo.Variables(i1).Name,'INST_REFERENCE') == 0
          eval(['nccreate(tempfile,finfo.Variables(i1).Name,''Dimensions'',{' ex1 '},''Datatype'',finfo.Variables(i1).Datatype,''Format'',''classic'');'])

        % attributes
        for i3=1:size(finfo.Variables(i1).Attributes,2)
            ncwriteatt(tempfile,finfo.Variables(i1).Name,finfo.Variables(i1).Attributes(i3).Name,finfo.Variables(i1).Attributes(i3).Value);
        end
    

        % data
        eval(['ncwrite(tempfile,finfo.Variables(i1).Name,' finfo.Variables(i1).Name ');'])
    end
end




% file open
ncid = netcdf.open([workpath tempfile],'NC_WRITE');

% 定義モードにする
netcdf.reDef(ncid);

% リネームする関数のIDを取得
renFuncID = netcdf.inqVarID(ncid,'DATA_TYPE');
renFuncID2 = netcdf.inqVarID(ncid,'FORMAT_VERSION');
renFuncID3 = netcdf.inqVarID(ncid,'HANDBOOK_VERSION');
renFuncID4 = netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME');
renFuncID5 = netcdf.inqVarID(ncid,'DATE_CREATION');
renFuncID6 = netcdf.inqVarID(ncid,'CALIBRATION_DATE');
% リネーム
netcdf.renameAtt(ncid,renFuncID,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID2,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID3,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID4,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID5,'comment','long_name');
netcdf.renameVar(ncid,renFuncID6,'SCIENTIFIC_CALIB_DATE');

% 項目追加
netcdf.putAtt(ncid,renFuncID,'conventions','Argo reference table 1');

% 項目削除
delFuncID = netcdf.inqVarID(ncid,'PRES');
netcdf.delAtt(ncid,delFuncID,'comment');
delFuncID2 = netcdf.inqVarID(ncid,'PRES_ADJUSTED');
netcdf.delAtt(ncid,delFuncID2,'comment');
delFuncID3 = netcdf.inqVarID(ncid,'TEMP');
netcdf.delAtt(ncid,delFuncID3,'comment');
delFuncID4 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED');
netcdf.delAtt(ncid,delFuncID4,'comment');
delFuncID5 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR');
netcdf.delAtt(ncid,delFuncID5,'comment');

% プロファイルによってはPSALが無いものがあるので以下は存在チェック
% ここだけ別のfunctionに飛ばす
ncid = exist_PSALcheck(ncid);
  


% SCIENTIFIC_CALIB_DATEはCALIBLATION_DATEをリネームして利用している
% FillValueを下に追加したいので一度項目を削除してあとで順番に追加する
delFuncID9 = netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE');
netcdf.delAtt(ncid,delFuncID9,'_FillValue');


% 7.11ドラフトで追加になった項目を書き出し
% PSAL_ADJUSTED_ERRORも追加なのだがPSALがないデータの場合は別関数(exist_PSALcheck)に移動
writeAttID1 = netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR');
netcdf.putAtt(ncid,writeAttID1,'long_name','Error on the adjusted values as determined by the delayed mode QC process');

writeAttID2 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR');
netcdf.putAtt(ncid,writeAttID2,'long_name','Error on the adjusted values as determined by the delayed mode QC process');


% ファイル書き込み
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);

% 3.1で増えた変数を追加、DBからデータも読んでおく
% データベース接続と変数への格納
% DBのIPアドレス直打ちなので、サーバリプレイス後にも以下の行は変更が必要
% 引越し後、動かそうとしたらSQLの構文変わってた、中島さんに見てもらって修正
logintimeout(5);
conn=database('argo2012','argo','argo','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.22.43:1521:');
%ex1=exec(conn,['select nvl(float_name,'' ''),nvl(float_sn,'' ''),nvl(firmware_version,'' ''),nvl(obs_mode,'' '') , nvl(sensor_caldate,'' '') from float_info,sensor_axis_info,m_float_types,sensor_param_info where sensor_axis_info.argo_id=float_info.argo_id and float_info.float_type_id=m_float_types.float_type_id and wmo_no=''' wmo ''' and axis_no=1 and param_id=1']);
ex1=exec(conn,['select nvl(float_name,'' ''),nvl(float_sn,'' ''),nvl(firmware_version,'' ''),nvl(obs_mode,'' '') ,nvl(to_char(sensor_caldate,''yyyymmddhhmiss''),'' '') from float_info,sensor_axis_info,m_float_types,sensor_param_info where sensor_axis_info.argo_id=float_info.argo_id and sensor_axis_info.argo_id=sensor_param_info.argo_id and sensor_axis_info.param_id=sensor_param_info.param_id and float_info.float_type_id=m_float_types.float_type_id and wmo_no=''' wmo ''' and axis_no=1 and sensor_axis_info.param_id=1']);
curs1=fetch(ex1);
close(conn);

platform_type=curs1.Data{1};
float_serial_no=curs1.Data{2};
firmware_version=curs1.Data{3};
vertical_sampling_scheme=curs1.Data{4};
%scienctific_calib_date=curs1.Data{5};

% 3.1で増えた変数を追加、一番下に追加されてしまう。。
nccreate([workpath tempfile],'PLATFORM_TYPE',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','long_name','Type of float');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','conventions','Argo reference table 23');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','_FillValue',' ');
ncwrite([workpath tempfile],'PLATFORM_TYPE',sprintf('%-32s',platform_type)');

nccreate([workpath tempfile],'FLOAT_SERIAL_NO',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'FLOAT_SERIAL_NO','long_name','Serial number of the float');
ncwriteatt([workpath tempfile],'FLOAT_SERIAL_NO','_FillValue',' ');
ncwrite([workpath tempfile],'FLOAT_SERIAL_NO',sprintf('%-32s',float_serial_no)');

nccreate([workpath tempfile],'FIRMWARE_VERSION',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'FIRMWARE_VERSION','long_name','Instrument firmware version');
ncwriteatt([workpath tempfile],'FIRMWARE_VERSION','_FillValue',' ');
ncwrite([workpath tempfile],'FIRMWARE_VERSION',sprintf('%-32s',firmware_version)');

nccreate([workpath tempfile],'VERTICAL_SAMPLING_SCHEME',...
    'Dimensions',{'STRING256','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','long_name','Vertical sampling scheme');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','conventions','Argo reference table 16');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','_FillValue',' ');
ncwrite([workpath tempfile],'VERTICAL_SAMPLING_SCHEME',sprintf('%-256s',vertical_sampling_scheme)');

nccreate([workpath tempfile],'CONFIG_MISSION_NUMBER',...
    'Dimensions',{'N_PROF'},'Datatype','int32');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','long_name','Unique number denoting the missions performed by the float');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','conventions','1..N , 1:first complete mission');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','_FillValue',99999);
ncwrite([workpath tempfile],'CONFIG_MISSION_NUMBER',1);

% format_version 2.2 > 3.1
ncwrite([workpath tempfile],'FORMAT_VERSION','3.1');

% 3.1で追加になったアトリビュートを追加
ncwriteatt([workpath tempfile],'JULD','standard_name','time');
ncwriteatt([workpath tempfile],'JULD','resolution','X');
ncwriteatt([workpath tempfile],'JULD','axis','T');

ncwriteatt([workpath tempfile],'JULD_LOCATION','resolution','X');

ncwriteatt([workpath tempfile],'LATITUDE','standard_name','latitude');
ncwriteatt([workpath tempfile],'LATITUDE','axis','Y');

ncwriteatt([workpath tempfile],'LONGITUDE','standard_name','longitude');
ncwriteatt([workpath tempfile],'LONGITUDE','axis','X');

ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','long_name','Date of calibration');
ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','conventions','YYYYMMDDHHMISS');
ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','_FillValue',' ');
%ncwrite([workpath tempfile],'SCIENTIFIC_CALIB_DATE',sprintf('%-14s',scienctific_calib_date)');

ncwriteatt([workpath tempfile],'PRES','standard_name','PRES');
ncwriteatt([workpath tempfile],'TEMP','standard_name','TEMP');
ncwriteatt([workpath tempfile],'PSAL','standard_name','PSAL');

ncwriteatt([workpath tempfile],'PRES_ADJUSTED','standard_name','PRES_ADJUSTED');
ncwriteatt([workpath tempfile],'TEMP_ADJUSTED','standard_name','TEMP_ADJUSTED');
ncwriteatt([workpath tempfile],'PSAL_ADJUSTED','standard_name','PSAL_ADJUSTED');

%
% tempfileを再読み込みしてマニュアル順に並び替える
%


% ファイルポインタ取得
finfo2 = ncinfo([workpath tempfile]);

% 以下tempfile書き出しと全く同じ
% netcdf 読み込み
% dimensions
for i1=1:size(finfo2.Dimensions,2)
    eval([finfo2.Dimensions(i1).Name '=finfo2.Dimensions(i1).Length;']);
end

% valiables
for i1=1:size(finfo2.Variables,2)
    eval([finfo2.Variables(i1).Name '=ncread([workpath tempfile],finfo2.Variables(i1).Name);']);
end

% 読み込んだので書きだす
% INST_REFERENCEは削除された変数なので、そこだけは書かないようにして書きだす

ncid2 = netcdf.create([workpath updatefile],'NC_NOCLOBBER');
for i1=1:size(finfo2.Dimensions,2)
    if strcmp(finfo2.Dimensions(i1).Name,'N_HISTORY') == 0
        netcdf.defDim(ncid2,finfo2.Dimensions(i1).Name,finfo2.Dimensions(i1).Length);
    end
end
netcdf.defDim(ncid2,'N_HISTORY',netcdf.getConstant('NC_UNLIMITED'));
netcdf.close(ncid2);


% write netcdf contents
% 追加パラメータを途中に追加させるために都合3回ループさせている
% case文の順番に書きだされる。
% もう少しスマートに書けないものか？

for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ここから
    switch (finfo2.Variables(i1).Name)
        case {'DATA_TYPE',...
              'FORMAT_VERSION',...
              'HANDBOOK_VERSION',...
              'REFERENCE_DATE_TIME',...
              'PLATFORM_NUMBER',...
              'PROJECT_NAME',...
              'PI_NAME',...
              'STATION_PARAMETERS',...
              'CYCLE_NUMBER',...
              'DIRECTION',...
              'DATA_CENTRE',...
              'DATE_CREATION',... % global attributesのhistoryに書く必要あり
              'DATE_UPDATE',... % global attributesのhistoryに書く必要あり
              'DC_REFERENCE',...
              'DATA_STATE_INDICATOR',...
              'DATA_MODE',...
              'PLATFORM_TYPE',... % PLATFORM_TYPE以降は3.1から増えた部分、tempfile.ncでは最後に追記されているのでループカウンタが最後まで行ってしまう
              'FLOAT_SERIAL_NO',...
              'FIRMWARE_VERSION'}

            eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
            % attributes
            for i3=1:size(finfo2.Variables(i1).Attributes,2)
                ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                if( strcmp(finfo2.Variables(i1).Name , DATE_CREATION) == 1) date_creation = finfo2.Variables(i1).Attributes(i3).Value;end
                if( strcmp(finfo2.Variables(i1).Name , DATE_UPDATE) == 1) date_update = finfo2.Variables(i1).Attributes(i3).Value;end

            end
            % data
            eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
    end
end
       
% 追加分は最後にあるのでループカウンタが最後まで行ってしまうので追加分より後に追加したい分のためにもう一回回す（2回め）
for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ここから
    switch (finfo2.Variables(i1).Name)
        
        case {'WMO_INST_TYPE',...
              'JULD',...
              'JULD_QC',...
              'JULD_LOCATION',...
              'LATITUDE',...
              'LONGITUDE',...
              'POSITION_QC',...
              'POSITIONING_SYSTEM',...
              'PROFILE_PRES_QC',...
              'PROFILE_TEMP_QC',...
              'PROFILE_PSAL_QC',...
              'VERTICAL_SAMPLING_SCHEME',... % 3,1から増えた部分
              'CONFIG_MISSION_NUMBER'}

            eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
            % attributes
            for i3=1:size(finfo2.Variables(i1).Attributes,2)
                ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
            end
            % data
            eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
    end
end
% 追加分は最後にあるのでループカウンタが最後まで行ってしまうので追加分より後に追加したい分のためにもう一回回す（3回め）
for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ここから
    switch (finfo2.Variables(i1).Name)

        case{ 'PRES',...
              'PRES_QC',...
              'PRES_ADJUSTED',...
              'PRES_ADJUSTED_QC',...
              'PRES_ADJUSTED_ERROR',...
              'TEMP',...
              'TEMP_QC',...
              'TEMP_ADJUSTED',...
              'TEMP_ADJUSTED_QC',...
              'TEMP_ADJUSTED_ERROR',...
              'PSAL',...
              'PSAL_QC',...
              'PSAL_ADJUSTED',...
              'PSAL_ADJUSTED_QC',...
              'PSAL_ADJUSTED_ERROR',...
              'PARAMETER',...
              'SCIENTIFIC_CALIB_EQUATION',...
              'SCIENTIFIC_CALIB_COEFFICIENT',...
              'SCIENTIFIC_CALIB_COMMENT',...
              'SCIENTIFIC_CALIB_DATE',...
              'HISTORY_INSTITUTION',...
              'HISTORY_STEP',...
              'HISTORY_SOFTWARE',...
              'HISTORY_SOFTWARE_RELEASE',...
              'HISTORY_REFERENCE',...
              'HISTORY_DATE',...
              'HISTORY_ACTION',...
              'HISTORY_PARAMETER',...
              'HISTORY_START_PRES',...
              'HISTORY_STOP_PRES',...
              'HISTORY_PREVIOUS_VALUE',...
              'HISTORY_QCTEST'}
       
            eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
            % attributes
            for i3=1:size(finfo2.Variables(i1).Attributes,2)
                ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
            end
            % data
            eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
   end
end

%
% グローバルアトリビュートは上の方法では読み書きが出来ていないので
% グローバルについては以下で追加する。
%

% historyにdate_creation と date_updateを書く、その上でこのプログラム実行時間をdata_updateに追記する

% file open
ncid = netcdf.open([workpath updatefile],'NC_WRITE');

% 定義モードにする
netcdf.reDef(ncid);

% グローバルアトリビュートの追加
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Argo float vertical profile');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'institution','JAMSTEC');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source','Argo float');
% history のフォーマット変更
%netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',datestr(now-9/24,'yyyy-mm-ddTHH:MM:SSZ update'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',date_creation);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'reference','reference');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'comment','comment');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'user_manual_version','3.1');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions','Argo-3.1 CF-1.6');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'featureType','trajectoryProfile');

% ファイル書き込み
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);


% デバッグプリント
%ncdisp(tempfile);

% Matlab自体も終了させる（自動起動スクリプト時に必要）
exit(0);
end

function ncid = exist_PSALcheck(ncid)
try
    delFuncID6 = netcdf.inqVarID(ncid,'PSAL');
    netcdf.delAtt(ncid,delFuncID6,'comment');
    delFuncID7 = netcdf.inqVarID(ncid,'PSAL_ADJUSTED');
    netcdf.delAtt(ncid,delFuncID7,'comment');
    delFuncID8 = netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR');
    netcdf.delAtt(ncid,delFuncID8,'comment');
    
    writeAttID3 = netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR');
    netcdf.putAtt(ncid,writeAttID3,'long_name','Error on the adjusted values as determined by the delayed mode QC process');

catch err
    return;
end
end