NetCDF Profile 3.1�R���o�[�g�c�[��
======================
ARGOS�ʐM�t���[�g��D�t�@�C���inetCDF Profile2.3)��  
Argo User's Manual�@Version2.31(2011�N6��14���Łj����Version3.1�iFIX������j�֕ϊ�����c�[��

 Matlab�iR2014a�j�ɂč쐬
 
�g����
------
### Matlab�R�}���h�E�C���h�E��� ###
    >>31conv  
 _���݂͓��o�̓t�@�C���Ƃ��ɃX�N���v�g�ɋL�q���Ă���_
 
�p�����[�^�̉��
----------------
����p�����[�^��n���đ�ʂɕϊ��ł���悤�ɂ���B
 
    >>31conv(param1)
 
+   `param1` :
    ���̓t�@�C�����A�������̓f�B���N�g�������w�肷��
 
����̗\��(�������ȋ@�\�j
--------
+ �f�[�^�x�[�X����̓ǂݎ��i�����Ă�������R�[�h�j

```c
logintimeout(5);  
conn=database('argo2012','argo','argo','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@192.168.16.201:1521:');
ex1=exec(conn,['select obs_mode from float_info,sensor_axis_info where sensor_axis_info.argo_id=float_info.argo_id  
and wmo_no='''wmo '''' ' and axis_no=1and param_id=1']);  
curs1=fetch(ex1);
close(conn);
ver_sam_sc=curs1.Data;
```

+ ���o�̓t�@�C���̌Œ艻����߂�  
    ���̓t�@�C���̎���������ł���Ɨǂ��iD�t�@�C���AR�t�@�C���Ƃ��邽�߁A�{�c�[����D�t�@�C���̂ݑΏہj
+ �G���[�`�F�b�N�̓���  
    Manual2.31�ł�FIRMWARE_VERSION�����邪�AJAMSTEC�����ݎ����Ă���Profile�ɂ͑��݂��Ȃ���
+ ���̑��v�������珑��

���C�Z���X
----------
 �ꉞ...  
Copyright &copy; 2014 JAMSTEC  
Distributed under the [MIT License][mit].  
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
