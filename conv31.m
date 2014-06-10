function conv31(filename)
workpath = '/home/argo/akazawa/';
readfile = 'tempfile.nc';

% ��������t�@�C���p�X�A�t�@�C�����𔲂��o��
% pathstr path�̕���
% name �g���q���������t�@�C��������
% ext �g���q
[pathstr,name,ext]=fileparts(filename);

% pathstr�̌��ɋ�؂�X���b�V��������
% origpath = strcat(pathstr,'/');

% �o�̓t�@�C��������� (���t�@�C��_NEW.nc)
updatefile = strcat(name,'_NEW',ext);

% DB����ǂނ̂ɕK�v��WMO�ԍ����t�@�C�������甲���o���B
wmo_no = strsplit(name,{'D','_'},'CollapseDelimiters',true);
wmo = wmo_no{2};

% �o�̓t�@�C���̃f�B���N�g��(��ƃf�B���N�g����WMO�ԍ��ō쐬�j
% �쐬�̓V�F���X�N���v�g�ł��\��E�E�E
% outpath = strcat(workpath,wmo,'/');

% �I���W�i���������Ȃ��悤�ɍ�ƃt�@�C���ɃR�s�[����
copyfile(filename,[workpath readfile]);

finfo = ncinfo([workpath readfile]);

% netcdf �ǂݍ���
% dimensions
for i1=1:size(finfo.Dimensions,2)
    eval([finfo.Dimensions(i1).Name '=finfo.Dimensions(i1).Length;']);
end

% valiables
for i1=1:size(finfo.Variables,2)
    eval([finfo.Variables(i1).Name '=ncread([workpath readfile],finfo.Variables(i1).Name);']);
end

% �ǂݍ��񂾂̂ŏ�������
% INST_REFERENCE�͍폜���ꂽ�ϐ��Ȃ̂ŁA���������͏����Ȃ��悤�ɂ��ď�������

ncid1 = netcdf.create([workpath updatefile],'NC_NOCLOBBER');
for i1=1:size(finfo.Dimensions,2)
    if strcmp(finfo.Dimensions(i1).Name,'N_HISTORY') == 0
        netcdf.defDim(ncid1,finfo.Dimensions(i1).Name,finfo.Dimensions(i1).Length);
    end
end
netcdf.defDim(ncid1,'N_HISTORY',netcdf.getConstant('NC_UNLIMITED'));
netcdf.close(ncid1);


% Variables INST_REFERENCE�������炻���͏����Ȃ��B�i�폜���ꂽ�ϐ��Ȃ̂Łj
% write netcdf contents

for i1=1:size(finfo.Variables,2)

    % variables
    ex1='';
    for i2=1:size(finfo.Variables(i1).Dimensions,2)
        ex1=[ex1 '''' finfo.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex1=ex1(1:end-1);
    
    if strcmp(finfo.Variables(i1).Name,'INST_REFERENCE') == 0
          eval(['nccreate(updatefile,finfo.Variables(i1).Name,''Dimensions'',{' ex1 '},''Datatype'',finfo.Variables(i1).Datatype,''Format'',''classic'');'])

        % attributes
        for i3=1:size(finfo.Variables(i1).Attributes,2)
            ncwriteatt(updatefile,finfo.Variables(i1).Name,finfo.Variables(i1).Attributes(i3).Name,finfo.Variables(i1).Attributes(i3).Value);
        end
    

        % data
        eval(['ncwrite(updatefile,finfo.Variables(i1).Name,' finfo.Variables(i1).Name ');'])
    end
end




% file open
ncid = netcdf.open([workpath updatefile],'NC_WRITE');

% ��`���[�h�ɂ���
netcdf.reDef(ncid);

% �O���[�o���A�g���r���[�g�̒ǉ�
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Argo float vertical profile');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'institution','JAMSTEC');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source','Argo float');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',datestr(now-9/24,'yyyy-mm-ddTHH:MM:SSZ creation'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'reference','reference');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'comment','comment');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'user_manual_version','3.1');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions','Argo-3.1 CF-1.6');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'featureType','trajectoryProfile');


% ���l�[������֐���ID���擾
renFuncID = netcdf.inqVarID(ncid,'DATA_TYPE');
renFuncID2 = netcdf.inqVarID(ncid,'FORMAT_VERSION');
renFuncID3 = netcdf.inqVarID(ncid,'HANDBOOK_VERSION');
renFuncID4 = netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME');
renFuncID5 = netcdf.inqVarID(ncid,'DATE_CREATION');
renFuncID6 = netcdf.inqVarID(ncid,'CALIBRATION_DATE');
% ���l�[��
netcdf.renameAtt(ncid,renFuncID,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID2,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID3,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID4,'comment','long_name');
netcdf.renameAtt(ncid,renFuncID5,'comment','long_name');
netcdf.renameVar(ncid,renFuncID6,'SCIENTIFIC_CALIB_DATE');

% ���ڍ폜
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



% �t�@�C����������
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);

% 3.1�ő������ϐ���ǉ��ADB����f�[�^���ǂ�ł���
% �f�[�^�x�[�X�ڑ��ƕϐ��ւ̊i�[
logintimeout(5);
conn=database('argo2012','argo','argo','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.16.201:1521:');
ex1=exec(conn,['select nvl(float_name,'' ''),nvl(float_sn,'' ''),nvl(firmware_version,'' ''),nvl(obs_mode,'' '') from float_info,sensor_axis_info,m_float_types where sensor_axis_info.argo_id=float_info.argo_id and float_info.float_type_id=m_float_types.float_type_id and wmo_no=''' wmo ''' and axis_no=1 and param_id=1']);
curs1=fetch(ex1);
close(conn);

platform_type=curs1.Data{1};
float_serial_no=curs1.Data{2};
firmware_version=curs1.Data{3};
vertical_sampling_scheme=curs1.Data{4};

% 
nccreate([workpath updatefile],'PLATFORM_TYPE',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath updatefile],'PLATFORM_TYPE','long_name','Type of float');
ncwriteatt([workpath updatefile],'PLATFORM_TYPE','conventions','Argo reference table 23');
ncwriteatt([workpath updatefile],'PLATFORM_TYPE','_FillValue',' ');
ncwrite([workpath updatefile],'PLATFORM_TYPE',sprintf('%-32s',platform_type)');

nccreate([workpath updatefile],'FLOAT_SERIAL_NO',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath updatefile],'FLOAT_SERIAL_NO','long_name','Serial number of the float');
ncwriteatt([workpath updatefile],'FLOAT_SERIAL_NO','_FillValue',' ');
ncwrite([workpath updatefile],'FLOAT_SERIAL_NO',sprintf('%-32s',float_serial_no)');

nccreate([workpath updatefile],'FIRMWARE_VERSION',...
    'Dimensions',{'STRING16','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath updatefile],'FIRMWARE_VERSION','long_name','Instrument firmware version');
ncwriteatt([workpath updatefile],'FIRMWARE_VERSION','_FillValue',' ');
ncwrite([workpath updatefile],'FIRMWARE_VERSION',sprintf('%-16s',firmware_version)');

nccreate([workpath updatefile],'VERTICAL_SAMPLING_SCHEME',...
    'Dimensions',{'STRING256','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath updatefile],'VERTICAL_SAMPLING_SCHEME','long_name','Vertical sampling scheme');
ncwriteatt([workpath updatefile],'VERTICAL_SAMPLING_SCHEME','conventions','Argo reference table 16');
ncwriteatt([workpath updatefile],'VERTICAL_SAMPLING_SCHEME','_FillValue',' ');
ncwrite([workpath updatefile],'VERTICAL_SAMPLING_SCHEME',sprintf('%-256s',vertical_sampling_scheme)');

nccreate([workpath updatefile],'CONFIG_MISSION_NUMBER',...
    'Dimensions',{'N_PROF'},'Datatype','int32');
ncwriteatt([workpath updatefile],'CONFIG_MISSION_NUMBER','long_name','Float mission number of each profile');
ncwriteatt([workpath updatefile],'CONFIG_MISSION_NUMBER','conventions','1..N , 1:first complete mission');
ncwriteatt([workpath updatefile],'CONFIG_MISSION_NUMBER','_FillValue',99999);
ncwrite([workpath updatefile],'CONFIG_MISSION_NUMBER',1);

% 3.1�Œǉ��ɂȂ����A�g���r���[�g��ǉ�
ncwriteatt([workpath updatefile],'JULD','standard_name','time');
ncwriteatt([workpath updatefile],'JULD','resolution','X');
ncwriteatt([workpath updatefile],'JULD','axis','T');

ncwriteatt([workpath updatefile],'JULD_LOCATION','resolution','X');

ncwriteatt([workpath updatefile],'LATITUDE','standard_name','latitude');
ncwriteatt([workpath updatefile],'LATITUDE','axis','Y');

ncwriteatt([workpath updatefile],'LONGITUDE','standard_name','longitude');
ncwriteatt([workpath updatefile],'LONGITUDE','axis','X');

ncwriteatt([workpath updatefile],'SCIENTIFIC_CALIB_DATE','long_name','Date of calibration');

ncwriteatt([workpath updatefile],'PRES','standard_name','PRES');
ncwriteatt([workpath updatefile],'TEMP','standard_name','TEMP');
ncwriteatt([workpath updatefile],'PSAL','standard_name','PSAL');

ncwriteatt([workpath updatefile],'PRES_ADJUSTED','standard_name','PRES_ADJUSTED');
ncwriteatt([workpath updatefile],'TEMP_ADJUSTED','standard_name','TEMP_ADJUSTED');
ncwriteatt([workpath updatefile],'PSAL_ADJUSTED','standard_name','PSAL_ADJUSTED');



% �f�o�b�O�v�����g
%ncdisp(updatefile);
