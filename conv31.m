function conv31(filename)

% ��ƃf�B���N�g���̏ꏊ�Atempfile.nc�͂����ɍ��
workpath = '/home/argo/akazawa/';

% ����t�@�C���p�X�A�t�@�C�����𔲂��o��
% pathstr path�̕���
% name �g���q���������t�@�C��������
% ext �g���q
[pathstr,name,ext]=fileparts(filename);

% pathstr�̌��ɋ�؂�X���b�V�������
% origpath = strcat(pathstr,'/');

% ���ԃt�@�C�������
% �����ڂ̏��Ԃ��Ⴄ�����Ȃ̂�machine readable�Ƃ��Ă͂��̃t�@�C���ł��ǂ�
tempfile = 'tempfile.nc';

% name�̐擪��R�t�@�C����������ϊ��ΏۊO�Ȃ̂Ńv���O�����I������
if strncmpi(name,'R',1) == 1
    exit(1);
end


% �ŏI�o�̓t�@�C��������� (���t�@�C��_NEW.nc)
updatefile = strcat(name,ext);

% DB����ǂނ̂ɕK�v��WMO�ԍ����t�@�C�������甲���o���B�iD�t�@�C���̂ݕϊ��Ώہj
wmo_no = strsplit(name,{'D','_'},'CollapseDelimiters',true);
wmo = wmo_no{2};

% �o�̓t�@�C���̃f�B���N�g��(��ƃf�B���N�g����WMO�ԍ��ō쐬�j
% �쐬�̓V�F���X�N���v�g�ł��\��E�E�E
% outpath = strcat(workpath,wmo,'/');


% �ȉ����珈���{�̕���
% �t�@�C���|�C���^�擾
finfo = ncinfo(filename);

% netcdf �ǂݍ���
% dimensions
for i1=1:size(finfo.Dimensions,2)
    eval([finfo.Dimensions(i1).Name '=finfo.Dimensions(i1).Length;']);
end

% valiables
for i1=1:size(finfo.Variables,2)
    eval([finfo.Variables(i1).Name '=ncread([filename],finfo.Variables(i1).Name);']);
end

% �ǂݍ��񂾂̂ŏ�������
% INST_REFERENCE�͍폜���ꂽ�ϐ��Ȃ̂ŁA���������͏����Ȃ��悤�ɂ��ď�������

ncid1 = netcdf.create([workpath tempfile],'NC_CLOBBER');
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


% ��`���[�h�ɂ���
netcdf.reDef(ncid);

% ���l�[������֐���ID���擾

% ���l�[��
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'DATA_TYPE'),'comment','long_name');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'FORMAT_VERSION'),'comment','long_name');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'HANDBOOK_VERSION'),'comment','long_name');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'),'comment','long_name');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'DATE_CREATION'),'comment','long_name');
netcdf.renameVar(ncid,netcdf.inqVarID(ncid,'CALIBRATION_DATE'),'SCIENTIFIC_CALIB_DATE');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'),'comment','long_name');
netcdf.renameAtt(ncid,netcdf.inqVarID(ncid,'PI_NAME'),'comment','long_name');

% ���ڒǉ�
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'DATA_TYPE'),'conventions','Argo reference table 1');

% 20150317 coresponding GDAC validation
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'CYCLE_NUMBER'),'conventions','0...N, 0 : launch cycle (if exists), 1 : first complete cycle');
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'JULD_QC'),'long_name','Quality on date and time');
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'long_name','Sea water pressure, equals 0 at sea-level');
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),'long_name','Sea water pressure, equals 0 at sea-level');
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'TEMP'),'long_name','Sea temperature in-situ ITS-90 scale');
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),'long_name','Sea temperature in-situ ITS-90 scale');

%20150515 PSAL ga nai profile tadasii taisaku.
% check exist PSAL
% dimension N_PARAM=2 is not PSAL , N_PARAM=3 is exist PSAL
if(N_PARAM == 3)
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'long_name','Practical salinity');
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),'long_name','Practical salinity');
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),'long_name','Contains the error on the adjusted values as determined by the delayed mode QC process');
end

% 20150317 put binary data(not ascii text)
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'TEMP'),'valid_min',single(-2.5));
netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),'valid_min',single(-2.5));

% ���ڍ폜
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'comment');
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),'comment');
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),'comment');
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'TEMP'),'comment');
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),'comment');
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),'comment');

% 20150515 PSAL ga nai profile tadasii taisaku.
if(N_PARAM == 3)
    netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'comment');
    netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),'comment');
    netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),'comment');
    
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'valid_max',single(41));
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'valid_min',single(2));
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),'valid_max',single(41));
    netcdf.putAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),'valid_min',single(2));
end

% SCIENTIFIC_CALIB_DATE��CALIBLATION_DATE�����l�[�����ė��p���Ă���
% FillValue�����ɒǉ��������̂ň�x���ڂ��폜���Ă��Ƃŏ��Ԃɒǉ�����
netcdf.delAtt(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),'_FillValue');


% 7.11�h���t�g�Œǉ��ɂȂ������ڂ������o��
% PSAL_ADJUSTED_ERROR���ǉ��Ȃ̂���PSAL���Ȃ��f�[�^�̏ꍇ�͕ʊ֐�(exist_PSALcheck)�Ɉړ�
writeAttID1 = netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR');
netcdf.putAtt(ncid,writeAttID1,'long_name','Contains the error on the adjusted values as determined by the delayed mode QC process');

writeAttID2 = netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR');
netcdf.putAtt(ncid,writeAttID2,'long_name','Contains the error on the adjusted values as determined by the delayed mode QC process');

netcdf.inqVarID(ncid,'HISTORY_INSTITUTION');

% �t�@�C����������
netcdf.endDef(ncid);

% 20150123 updated
% get current dim length
[dimname,dimlen] = netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_HISTORY'));

histID1 = netcdf.inqVarID(ncid,'HISTORY_INSTITUTION');
writeInst = netcdf.getVar(ncid,histID1);
instVal = 'JM  '; % const char
instVal = instVal(:); % reshape 1x4 to 4x1
writeInst(:,:,dimlen+1) = instVal; % add to end of table

histID2 = netcdf.inqVarID(ncid,'HISTORY_SOFTWARE');
writeSW = netcdf.getVar(ncid,histID2);
softVal = 'JMFC';
softVal = softVal(:);
writeSW(:,:,dimlen+1) = softVal;

histID3 = netcdf.inqVarID(ncid,'HISTORY_SOFTWARE_RELEASE');
writeSR = netcdf.getVar(ncid,histID3);
srVal = '1.0 ';
srVal = srVal(:);
writeSR(:,:,dimlen+1) = srVal;

histID4 = netcdf.inqVarID(ncid,'HISTORY_DATE');
writeDaTe = netcdf.getVar(ncid,histID4);
dateVal = datestr(now-9/24,'yyyymmddHHMMSS');
dateVal = dateVal(:);
writeDaTe(:,:,dimlen+1) = dateVal;


netcdf.sync(ncid);
netcdf.close(ncid);




% 3.1�ő������ϐ���ǉ��ADB����f�[�^���ǂ�ł���
% �f�[�^�x�[�X�ڑ��ƕϐ��ւ̊i�[
% DB��IP�A�h���X���ł��Ȃ̂ŁA�T�[�o���v���C�X��ɂ��ȉ��̍s�͕ύX���K�v
% ��z����A���������Ƃ�����SQL�̍\���ς���Ă��A��������Ɍ��Ă�����ďC��
logintimeout(5);
conn=database('argo2012.hq.jamstec.go.jp','argo','argo','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@//192.168.22.43:1521/');
ex1=exec(conn,['select nvl(float_sn,'' ''),nvl(firmware_version,'' ''),float_type_id,argo_id,float_manufac_id from float_info where wmo_no=''' wmo '''']);
curs1=fetch(ex1);
float_serial_no=curs1.Data{1}; % in use!
firmware_version=curs1.Data{2};% in use!
float_type_id=curs1.Data{3}; % this param is next SQL use.
argo_id=curs1.Data{4}; % this param is next SQL use.
float_manufac_id=curs1.Data{5}; % 20150311 add to check platform_type(MetOcean ID is 9)

ex11=exec(conn,['select nvl(float_name,'' '') from m_float_types where float_type_id=' num2str(float_type_id) ]);
curs2=fetch(ex11);
platform_type=curs2.Data;% in use!

if float_manufac_id == 9
    platform_type='PROVOR_MT';
    platform_type=cellstr(platform_type);
end

ex12=exec(conn,['select nvl(vertical_sampling_scheme,'' '') from float_mission_param_info where param_id=3 and argo_id=''' argo_id '''']);
curs3=fetch(ex12);

vertical_sampling_scheme=curs3.Data;% in use!

%keyboard % this is debug stop command!!
close(conn);


% 3.1�ő������ϐ���ǉ��A��ԉ��ɒǉ�����Ă��܂��B�B
nccreate([workpath tempfile],'PLATFORM_TYPE',...
    'Dimensions',{'STRING32','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','long_name','Type of float');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','conventions','Argo reference table 23');
ncwriteatt([workpath tempfile],'PLATFORM_TYPE','_FillValue',' ');
ncwrite([workpath tempfile],'PLATFORM_TYPE',sprintf('%-32s',cell2mat(platform_type))');

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
ncwrite([workpath tempfile],'VERTICAL_SAMPLING_SCHEME',sprintf('%-256s',cell2mat(vertical_sampling_scheme))');

nccreate([workpath tempfile],'CONFIG_MISSION_NUMBER',...
    'Dimensions',{'N_PROF'},'Datatype','int32');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','long_name','Unique number denoting the missions performed by the float');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','conventions','1...N, 1 : first complete mission');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','_FillValue',str2num('int32(99999)'));

ncwrite([workpath tempfile],'CONFIG_MISSION_NUMBER',1);

% format_version 2.2 > 3.1
ncwrite([workpath tempfile],'FORMAT_VERSION','3.1');

% 3.1�Œǉ��ɂȂ����A�g���r���[�g��ǉ�
ncwriteatt([workpath tempfile],'JULD','standard_name','time');
ncwriteatt([workpath tempfile],'JULD','resolution',str2num('1.e-5'));
ncwriteatt([workpath tempfile],'JULD','axis','T');

ncwriteatt([workpath tempfile],'JULD_LOCATION','resolution',str2num('1.e-5'));

ncwriteatt([workpath tempfile],'LATITUDE','standard_name','latitude');
ncwriteatt([workpath tempfile],'LATITUDE','axis','Y');

ncwriteatt([workpath tempfile],'LONGITUDE','standard_name','longitude');
ncwriteatt([workpath tempfile],'LONGITUDE','axis','X');

ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','long_name','Date of calibration');
ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','conventions','YYYYMMDDHHMISS');
ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','_FillValue',' ');
%ncwrite([workpath tempfile],'SCIENTIFIC_CALIB_DATE',sprintf('%-14s',scienctific_calib_date)');

ncwriteatt([workpath tempfile],'PRES','standard_name','sea_water_pressure');
ncwriteatt([workpath tempfile],'TEMP','standard_name','sea_water_temperature');

if(N_PARAM == 3)
    ncwriteatt([workpath tempfile],'PSAL','standard_name','sea_water_salinity');
    ncwriteatt([workpath tempfile],'PSAL_ADJUSTED','standard_name','sea_water_salinity');
end

ncwriteatt([workpath tempfile],'PRES_ADJUSTED','standard_name','sea_water_pressure');
ncwriteatt([workpath tempfile],'TEMP_ADJUSTED','standard_name','sea_water_temperature');

ncwriteatt([workpath tempfile],'PRES','axis','Z');

% 20150123 add parameter
ncwrite([workpath tempfile],'HISTORY_INSTITUTION',writeInst);
ncwrite([workpath tempfile],'HISTORY_SOFTWARE',writeSW);
ncwrite([workpath tempfile],'HISTORY_SOFTWARE_RELEASE',writeSR);
ncwrite([workpath tempfile],'HISTORY_DATE',writeDaTe);

save_updatedate = DATE_UPDATE;
ncwrite([workpath tempfile],'DATE_UPDATE',datestr(now-9/24,'yyyymmddHHMMSS'));


%
% tempfile���ēǂݍ��݂��ă}�j���A�����ɕ��ёւ���
%


% �t�@�C���|�C���^�擾
finfo2 = ncinfo([workpath tempfile]);

% �ȉ�tempfile�����o���ƑS������
% netcdf �ǂݍ���
% dimensions
for i1=1:size(finfo2.Dimensions,2)
    eval([finfo2.Dimensions(i1).Name '=finfo2.Dimensions(i1).Length;']);
end

% valiables
for i1=1:size(finfo2.Variables,2)
    eval([finfo2.Variables(i1).Name '=ncread([workpath tempfile],finfo2.Variables(i1).Name);']);
end

% �ǂݍ��񂾂̂ŏ�������
% INST_REFERENCE�͍폜���ꂽ�ϐ��Ȃ̂ŁA���������͏����Ȃ��悤�ɂ��ď�������

ncid2 = netcdf.create([workpath updatefile],'NC_NOCLOBBER');
for i1=1:size(finfo2.Dimensions,2)
    if strcmp(finfo2.Dimensions(i1).Name,'N_HISTORY') == 0
        netcdf.defDim(ncid2,finfo2.Dimensions(i1).Name,finfo2.Dimensions(i1).Length);
    end
end
netcdf.defDim(ncid2,'N_HISTORY',netcdf.getConstant('NC_UNLIMITED'));
netcdf.close(ncid2);


% write netcdf contents
% �ǉ��p�����[�^��r���ɒǉ������邽�߂ɓs��3�񃋁[�v�����Ă���
% case���̏��Ԃɏ����������B
% ���������X�}�[�g�ɏ����Ȃ����̂��H

for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ��������
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
              'DATE_CREATION',... % global attributes��history�ɏ����K�v����
              'DATE_UPDATE',... % global attributes��history�ɏ����K�v����
              'DC_REFERENCE',...
              'DATA_STATE_INDICATOR',...
              'DATA_MODE',...
              'PLATFORM_TYPE',... % PLATFORM_TYPE�ȍ~��3.1���瑝���������Atempfile.nc�ł͍Ō�ɒǋL����Ă���̂Ń��[�v�J�E���^���Ō�܂ōs���Ă��܂�
              'FLOAT_SERIAL_NO',...
              'FIRMWARE_VERSION'}

            eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
            % attributes
            for i3=1:size(finfo2.Variables(i1).Attributes,2)
                ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
            end
            % data
            eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
    end
end
       
% �ǉ����͍Ō�ɂ���̂Ń��[�v�J�E���^���Ō�܂ōs���Ă��܂��̂Œǉ�������ɒǉ����������̂��߂ɂ������񂷁i2��߁j
for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ��������
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
              'VERTICAL_SAMPLING_SCHEME',... % 3,1���瑝��������
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
% �ǉ����͍Ō�ɂ���̂Ń��[�v�J�E���^���Ō�܂ōs���Ă��܂��̂Œǉ�������ɒǉ����������̂��߂ɂ������񂷁i3��߁j
for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);
    
    % ��������
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
% �O���[�o���A�g���r���[�g�͏�̕�@�ł͓ǂݏ������o���Ă��Ȃ��̂�
% �O���[�o���ɂ��Ă͈ȉ��Œǉ�����B
%

% history��date_creation �� date_update�������A���̏�ł��̃v���O�������s���Ԃ�data_update�ɒǋL����

% file open
ncid = netcdf.open([workpath updatefile],'NC_WRITE');

% ��`���[�h�ɂ���
netcdf.reDef(ncid);

% �O���[�o���A�g���r���[�g�̒ǉ�
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Argo float vertical profile');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'institution','JAMSTEC');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'source','Argo float');
% history �̃t�H�[�}�b�g�ύX
print_hist = formatHistory(DATE_CREATION,save_updatedate);

%netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',datestr(now-9/24,'yyyy-mm-ddTHH:MM:SSZ update'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',print_hist);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'references','http://www.argodatamgt.org/Documentation');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'comment','free text');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'user_manual_version','3.1');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions','Argo-3.1 CF-1.6');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'featureType','trajectoryProfile');

% �t�@�C����������
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);


% �f�o�b�O�v�����g
%ncdisp(tempfile);

% Matlab���̂��I��������i�����N���X�N���v�g���ɕK�v�j

exit(0);
end


function print_hist = formatHistory(DATE_CREATION,save_updatedate)
    % format creation date
    dc = reshape(DATE_CREATION,1,[]);
    print_hist = strcat(dc(1:4),'-',dc(5:6),'-',dc(7:8),'T',dc(9:10),':',dc(11:12),':',dc(13:14),'Z creation;');
    
    % format update date
    du = reshape(save_updatedate,1,[]);
    print_hist = strcat(print_hist,du(1:4),'-',du(5:6),'-',du(7:8),'T',du(9:10),':',du(11:12),':',du(13:14),'Z update;');
    
    % add this tool execute date(UPDATE)
    print_hist = strcat(print_hist,datestr(now-9/24,'yyyy-mm-ddTHH:MM:SS'));
    print_hist = strcat(print_hist,'Z conversion to V3.1;');
end