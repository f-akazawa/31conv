copyfile(which('Rtest.nc'),'c:\Github\31conv\myfile.nc');
%fileattrib('myfile.nc','+w');
% file open
ncid = netcdf.open('myfile.nc','NC_WRITE')

% 定義モードにする
netcdf.reDef(ncid);

% グローバルアトリビュートの追加
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Argo float vertical profile');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'institution','JAMSTEC');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source','Argo float');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history','history');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'reference','reference');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'comment','comment');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'user_manual_version','3.1');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions','Argo-3.1 CF-1.6');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'featureType','trajectoryProfile');


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

% 項目削除
delFuncID = netcdf.inqVarID(ncid,'PRES');
netcdf.delAtt(ncid,delFuncID,'comment');
delFuncID2 = netcdf.inqVarID(ncid,'PRES_ADJUSTED');
netcdf.delAtt(ncid,delFuncID2,'comment');
delFuncID3 = netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR');
netcdf.delAtt(ncid,delFuncID3,'comment');

delFuncID4 = netcdf.inqVarID(ncid,'TEMP');
netcdf.delAtt(ncid,delFuncID4,'comment');
delFuncID5 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED');
netcdf.delAtt(ncid,delFuncID5,'comment');
delFuncID6 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR');
netcdf.delAtt(ncid,delFuncID6,'comment');

delFuncID7 = netcdf.inqVarID(ncid,'PSAL');
netcdf.delAtt(ncid,delFuncID7,'comment');
delFuncID8 = netcdf.inqVarID(ncid,'PSAL_ADJUSTED');
netcdf.delAtt(ncid,delFuncID8,'comment');
delFuncID9 = netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR');
netcdf.delAtt(ncid,delFuncID9,'comment');



% ファイル書き込み
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);

% 3.1で増えた変数を追加
nccreate('myfile.nc','PLATFORM_TYPE',...
    'Dimensions',{'N_PROF','STRING32'},...
    'Datatype','char');
ncwriteatt('myfile.nc','PLATFORM_TYPE','long_name','Type of float');
ncwriteatt('myfile.nc','PLATFORM_TYPE','_FillValue',' ');

nccreate('myfile.nc','FLOAT_SERIAL_NO',...
    'Dimensions',{'N_PROF','STRING32'},...
    'Datatype','char');
ncwriteatt('myfile.nc','FLOAT_SERIAL_NO','long_name','Serial number of the float');
ncwriteatt('myfile.nc','FLOAT_SERIAL_NO','_FillValue',' ');

nccreate('myfile.nc','FIRMWARE_VERSION',...
    'Dimensions',{'N_PROF','STRING16'},...
    'Datatype','char');
ncwriteatt('myfile.nc','FIRMWARE_VERSION','long_name','Instrument firmware version');
ncwriteatt('myfile.nc','FIRMWARE_VERSION','_FillValue',' ');

nccreate('myfile.nc','VERTICAL_SAMPLING_SCHEME',...
    'Dimensions',{'N_PROF','STRING256'},...
    'Datatype','char');
ncwriteatt('myfile.nc','VERTICAL_SAMPLING_SCHEME','long_name','Vertical sampling scheme');
ncwriteatt('myfile.nc','VERTICAL_SAMPLING_SCHEME','conventions','Argo reference table 16');
ncwriteatt('myfile.nc','VERTICAL_SAMPLING_SCHEME','_FillValue',' ');

nccreate('myfile.nc','CONFIG_MISSION_NUMBER',...
    'Dimensions',{'N_PROF'},'Datatype','int32');
ncwriteatt('myfile.nc','CONFIG_MISSION_NUMBER','long_name','Float mission number of each profile');
ncwriteatt('myfile.nc','CONFIG_MISSION_NUMBER','conventions','1..N , 1:first complete mission');
ncwriteatt('myfile.nc','CONFIG_MISSION_NUMBER','_FillValue',' ');

% 3.1で追加になったアトリビュートを追加
ncwriteatt('myfile.nc','JULD','standard_name','time');
ncwriteatt('myfile.nc','JULD','resolution','X');
ncwriteatt('myfile.nc','JULD','axis','T');

ncwriteatt('myfile.nc','JULD_LOCATION','resolution','X');

ncwriteatt('myfile.nc','LATITUDE','standard_name','latitude');
ncwriteatt('myfile.nc','LATITUDE','axis','Y');

ncwriteatt('myfile.nc','LONGITUDE','standard_name','longitude');
ncwriteatt('myfile.nc','LONGITUDE','axis','X');

ncwriteatt('myfile.nc','SCIENTIFIC_CALIB_DATE','long_name','Date of calibration');

ncwriteatt('myfile.nc','PRES','standard_name','PRES');
ncwriteatt('myfile.nc','TEMP','standard_name','TEMP');
ncwriteatt('myfile.nc','PSAL','standard_name','PSAL');

ncwriteatt('myfile.nc','PRES_ADJUSTED','standard_name','PRES_ADJUSTED');
ncwriteatt('myfile.nc','TEMP_ADJUSTED','standard_name','TEMP_ADJUSTED');
ncwriteatt('myfile.nc','PSAL_ADJUSTED','standard_name','PSAL_ADJUSTED');




% デバッグプリント
%ncdisp('myfile.nc','PLATFORM_TYPE');
