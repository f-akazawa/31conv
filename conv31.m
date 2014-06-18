function conv31(filename)

% ��ƃf�B���N�g���̏ꏊ�Atempfile.nc�͂����ɍ��
workpath = '/home/argo/akazawa/';

% ��������t�@�C���p�X�A�t�@�C�����𔲂��o��
% pathstr path�̕���
% name �g���q���������t�@�C��������
% ext �g���q
[pathstr,name,ext]=fileparts(filename);

% pathstr�̌��ɋ�؂�X���b�V��������
% origpath = strcat(pathstr,'/');

% ���ԃt�@�C�������
% �����ڂ̏��Ԃ��Ⴄ�����Ȃ̂�machine readable�Ƃ��Ă͂��̃t�@�C���ł��ǂ�
tempfile = 'tempfile.nc';

% �ŏI�o�̓t�@�C��������� (���t�@�C��_NEW.nc)
updatefile = strcat(name,'_NEW',ext);

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

% 3.1�ő������ϐ���ǉ��A��ԉ��ɒǉ�����Ă��܂��B�B
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
    'Dimensions',{'STRING16','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'FIRMWARE_VERSION','long_name','Instrument firmware version');
ncwriteatt([workpath tempfile],'FIRMWARE_VERSION','_FillValue',' ');
ncwrite([workpath tempfile],'FIRMWARE_VERSION',sprintf('%-16s',firmware_version)');

nccreate([workpath tempfile],'VERTICAL_SAMPLING_SCHEME',...
    'Dimensions',{'STRING256','N_PROF'},...
    'Datatype','char');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','long_name','Vertical sampling scheme');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','conventions','Argo reference table 16');
ncwriteatt([workpath tempfile],'VERTICAL_SAMPLING_SCHEME','_FillValue',' ');
ncwrite([workpath tempfile],'VERTICAL_SAMPLING_SCHEME',sprintf('%-256s',vertical_sampling_scheme)');

nccreate([workpath tempfile],'CONFIG_MISSION_NUMBER',...
    'Dimensions',{'N_PROF'},'Datatype','int32');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','long_name','Float mission number of each profile');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','conventions','1..N , 1:first complete mission');
ncwriteatt([workpath tempfile],'CONFIG_MISSION_NUMBER','_FillValue',99999);
ncwrite([workpath tempfile],'CONFIG_MISSION_NUMBER',1);

% format_version 2.2 > 3.1
ncwrite([workpath tempfile],'FORMAT_VERSION','3.1');

% 3.1�Œǉ��ɂȂ����A�g���r���[�g��ǉ�
ncwriteatt([workpath tempfile],'JULD','standard_name','time');
ncwriteatt([workpath tempfile],'JULD','resolution','X');
ncwriteatt([workpath tempfile],'JULD','axis','T');

ncwriteatt([workpath tempfile],'JULD_LOCATION','resolution','X');

ncwriteatt([workpath tempfile],'LATITUDE','standard_name','latitude');
ncwriteatt([workpath tempfile],'LATITUDE','axis','Y');

ncwriteatt([workpath tempfile],'LONGITUDE','standard_name','longitude');
ncwriteatt([workpath tempfile],'LONGITUDE','axis','X');

ncwriteatt([workpath tempfile],'SCIENTIFIC_CALIB_DATE','long_name','Date of calibration');

ncwriteatt([workpath tempfile],'PRES','standard_name','PRES');
ncwriteatt([workpath tempfile],'TEMP','standard_name','TEMP');
ncwriteatt([workpath tempfile],'PSAL','standard_name','PSAL');

ncwriteatt([workpath tempfile],'PRES_ADJUSTED','standard_name','PRES_ADJUSTED');
ncwriteatt([workpath tempfile],'TEMP_ADJUSTED','standard_name','TEMP_ADJUSTED');
ncwriteatt([workpath tempfile],'PSAL_ADJUSTED','standard_name','PSAL_ADJUSTED');

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

wline=1;
for i1=1:size(finfo2.Variables,2)

    % variables
    ex2='';
    for i2=1:size(finfo2.Variables(i1).Dimensions,2)
        ex2=[ex2 '''' finfo2.Variables(i1).Dimensions(i2).Name ''',' num2str(finfo2.Variables(i1).Dimensions(i2).Length) ','];
    end
    ex2=ex2(1:end-1);

    % ��������
    switch (finfo2.Variables(i1).Name)
        case ('DATA_TYPE')
            % �������珑���o������
            eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
            % attributes
            for i3=1:size(finfo2.Variables(i1).Attributes,2)
                ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
            end
            % data
            eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
            % �����܂ł������o������
            wline=wline+1;
        case ('FORMAT_VERSION')
            %if(wline ==2)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HANDBOOK_VERSION')
            %if(wline ==3)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('REFERENCE_DATE_TIME')
            %if(wline ==4)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PLATFORM_NUMBER')
            %if(wline ==5)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PROJECT_NAME')
            %if(wline ==6)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PI_NAME')
            %if(wline ==7)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('STATION_PARAMETERS')
            %if(wline ==8)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('CYCLE_NUMBER')
            %if(wline ==9)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DIRECTION')
            %if(wline ==10)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DATA_CENTRE')
            %if(wline ==11)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DATE_CREATION')
            %if(wline ==12)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DATE_UPDATE')
            %if(wline ==13)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DC_REFERENCE')
            %if(wline ==14)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DATA_STATE_INDICATOR')
            %if(wline ==15)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('DATA_MODE')
            %if(wline ==16)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PLATFORM_TYPE')
            %if(wline ==17)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('FLOAT_SERIAL_NO')
            %if(wline ==18)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('FIRMWARE_VERSION')
            %if(wline ==19)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('WMO_INST_TYPE')
            %if(wline ==20)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('JULD')
            %if(wline ==21)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('JULD_QC')
            %if(wline ==22)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('JULD_LOCATION')
            %if(wline ==23)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('LATITUDE')
            %if(wline ==24)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('LONGITUDE')
            %if(wline ==25)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('POSITION_QC')
            %if(wline ==26)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('POSITIONING_SYSTEM')
            %if(wline ==27)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PROFILE_PRES_QC')
            %if(wline ==28)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PROFILE_TEMP_QC')
            %if(wline ==29)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PROFILE_PSAL_QC')
            %if(wline ==30)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('VERTICAL_SAMPLING_SCHEME')
            %if(wline ==31)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('CONFIG_MISSION_NUMBER')
            %if(wline ==32)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PRES')
            %if(wline ==33)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PRES_QC')
            %if(wline ==34)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PRES_ADJUSTED')
            %if(wline ==35)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PRES_ADJUSTED_QC')
            %if(wline ==36)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PRES_ADJUSTED_ERROR')
            %if(wline ==37)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('TEMP')
            %if(wline ==38)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('TEMP_QC')
            %if(wline ==39)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('TEMP_ADJUSTED')
            %if(wline ==40)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('TEMP_ADJUSTED_QC')
            %if(wline ==41)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('TEMP_ADJUSTED_ERROR')
            %if(wline ==42)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PSAL')
            %if(wline ==43)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PSAL_QC')
            %if(wline ==44)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PSAL_ADJUSTED')
            %if(wline ==45)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PSAL_ADJUSTED_QC')
            %if(wline ==46)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PSAL_ADJUSTED_ERROR')
            %if(wline ==47)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('PARAMETER')
            %if(wline ==48)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('SCIENTIFIC_CALIB_EQUATION')
            %if(wline ==49)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('SCIENTIFIC_CALIB_COEFFICIENT')
            %if(wline ==50)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('SCIENTIFIC_CALIB_COMMENT')
            %if(wline ==51)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('SCIENTIFIC_CALIB_DATE')
            %if(wline ==52)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_INSTITUTION')
            %if(wline ==53)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_STEP')
            %if(wline ==54)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_SOFTWARE')
            %if(wline ==55)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_SOFTWARE_RELEASE')
            %if(wline ==56)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_REFERENCE')
            %if(wline ==57)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_DATE')
            %if(wline ==58)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_ACTION')
            %if(wline ==59)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_PARAMETER')
            %if(wline ==60)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
             %end
        case ('HISTORY_START_PRES')
             %if(wline ==61)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_STOP_PRES')
            %if(wline ==62)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_PREVIOUS_VALUE')
            %if(wline ==62)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
        case ('HISTORY_QCTEST')
            %if(wline ==63)
                % �������珑���o������
                eval(['nccreate(updatefile,finfo2.Variables(i1).Name,''Dimensions'',{' ex2 '},''Datatype'',finfo2.Variables(i1).Datatype,''Format'',''classic'');'])
                % attributes
                for i3=1:size(finfo2.Variables(i1).Attributes,2)
                    ncwriteatt(updatefile,finfo2.Variables(i1).Name,finfo2.Variables(i1).Attributes(i3).Name,finfo2.Variables(i1).Attributes(i3).Value);
                end
                % data
                eval(['ncwrite(updatefile,finfo2.Variables(i1).Name,' finfo2.Variables(i1).Name ');'])
                % �����܂ł������o������
                wline=wline+1;
            %end
    end
end

%
% �O���[�o���A�g���r���[�g�͏�̕��@�ł͓ǂݏ������o���Ȃ��̂�
% �O���[�o���ɂ��Ă͍Ō�ɒǉ�����B
%

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

% �t�@�C����������
netcdf.endDef(ncid);
netcdf.sync(ncid);
netcdf.close(ncid);


% �f�o�b�O�v�����g
%ncdisp(tempfile);
