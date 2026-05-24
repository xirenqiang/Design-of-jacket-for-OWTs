function [F1,M1,F50,M50,F2,M2]=Hydro_load_1and50yrs(Hm2,Tm2,DAF2,Hm50,Tm50,DAF50,Hm1,Tm1,DAF1,t0,t1,dt,Member_group,y0_position,beta_wave)
% 璇ュ嚱鏁扮敤浜庤�＄畻瀵肩�℃灦閮ㄥ垎鏉嗕欢鍙楀埌鐨勯噸鐜版湡涓�1year鍜�50year鐨勬按鍔ㄥ姏鑽疯浇锛岃�ヨ嵎杞藉悜鎵€鑰冭檻鏉嗕欢闆嗗悎(Member_group)鐨勬渶涓嬪眰涓�蹇冨�勭畝鍖栵紝鐢ㄤ簬纭�瀹氳�ュ眰鏉嗕欢鐨勫唴鍔涳紱
% 杈撳叆鍙橀噺锛�
% - Hm50锛氶噸鐜版湡50year娉㈡氮鐨勬渶澶ф尝楂橈紱
% - Tm50锛氶噸鐜版湡50year娉㈡氮鐨勫懆鏈燂紱
% - DAF50锛氶噸鐜版湡50year娉㈡氮鍛ㄦ湡鐨勭粨鏋勫姩鍔涙斁澶х郴鏁帮紱
% - Hm1锛氶噸鐜版湡1year鐨勬渶澶ф尝楂橈紱
% - Tm1锛氶噸鐜版湡1year娉㈡氮鐨勫懆鏈燂紱
% - DAF1锛氶噸鐜版湡1year娉㈡氮鍛ㄦ湡鐨勭粨鏋勫姩鍔涙斁澶х郴鏁帮紱
% - t0锛氳�＄畻璧峰�嬫椂闂达紱
% - t1锛氳�＄畻缁堟�㈡椂闂达紱
% - dt锛氭椂闂存�ラ暱锛�
% - Member_group锛�
% 杈撳嚭鍙橀噺锛�
% - F1锛氶噸鐜版湡1year娉㈡氮浣滅敤涓嬫渶澶ц嵎杞斤紱
% - M1锛氶噸鐜版湡1year娉㈡氮浣滅敤涓嬫渶澶у集鐭╋紱
% - F50锛氶噸鐜版湡50year娉㈡氮浣滅敤涓嬫渶澶ц嵎杞斤紱
% - M50锛氶噸鐜版湡50year娉㈡氮浣滅敤涓嬫渶澶у集鐭╋紱
% 杈撳叆鍙傛暟妫€楠岋細
global debug;
if debug==1
    if Hm2<0
        error('m20Hydro_load_1and50yrsHm2');
    end
    if Tm2<0
        error('m20Hydro_load_1and50yrsTm2');
    end
    if Hm50<0
        error('m500Hydro_load_1and50yrsHm50');
    end
    if Tm50<0
        error('m500Hydro_load_1and50yrsTm50');
    end
    if DAF50<0
        error('AF500Hydro_load_1and50yrsDAF50');
    end
    if Hm1<0
        error('m10Hydro_load_1and50yrsHm1');
    end
    if Tm1<0
        error('m10Hydro_load_1and50yrsTm1');
    end
    if DAF1<0
        error('AF10Hydro_load_1and50yrsDAF1');
    end
    if t0<0
        error('00Hydro_load_1and50yrst0');
    end
    if t1<0
        error('10Hydro_load_1and50yrst1');
    end
    if dt<0
        error('t0Hydro_load_1and50yrsdt');
    end
    if any(Member_group(:)<0)
        error('ember_group0Hydro_load_1and50yrsMember_group');
    end
end
% Main function:
global Wave;
if nargin < 16 || isempty(beta_wave)
    beta_wave = 0;
end
Wave.beta_propagation = beta_wave;
Wave.T=Tm50;%50-year extreme wave period
Wave.h=Hm50;%50骞存瀬绔�娉㈤珮
Wave.k=wave_number(Wave.T,Wave.h);%娉㈡暟
[Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_50y_max,Fty_50y_max,Ftz_50y_max,Mtx_50y_max,Mtz_50y_max]=Hydro_load_max(Ftx_50y,Fty_50y,Ftz_50y,Mtx_50y,Mtz_50y);
if debug==1
    if size(Ftx_50y)~=size(t)
        error('tx_50yHydro_load_1and50yrsFtx_50y');
    end
    if Fty_50y_max<0
        error('ty_50y_max0Hydro_load_1and50yrsFty_50y_max');
    end
    if Ftz_50y_max<0
        error('tz_50y_max0Hydro_load_1and50yrsFtz_50y_max');
    end
    if Mtx_50y_max<0
        error('tx_50y_max0Hydro_load_1and50yrsMtx_50y_max');
    end
end
F50ND=Ftx_50y_max;
M50ND=Mtz_50y_max;
F50=DAF50*F50ND;%鍩轰簬鍔ㄦ€佹斁澶х郴鏁帮紝50骞存瀬绔�娴峰喌涓嬪�肩�℃灦鍙楃殑鍔�
M50=DAF50*M50ND;%鍩轰簬鍔ㄦ€佹斁澶х郴鏁帮紝50骞存瀬绔�娴峰喌涓嬪�肩�℃灦鍙楃殑鍔涚煩

Wave.T=Tm1;%涓€骞存瀬绔�娉㈤珮鐨勫懆鏈�
Wave.h=Hm1;%涓€骞存瀬绔�娉㈤珮
Wave.k=wave_number(Wave.T,Wave.h);%娉㈡暟
[Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_1y_max,Fty_1y_max,Ftz_1y_max,Mtx_1y_max,Mtz_1y_max]=Hydro_load_max(Ftx_1y,Fty_1y,Ftz_1y,Mtx_1y,Mtz_1y);
if debug==1
    if size(Ftx_1y)~=size(t)
        error('tx_1yHydro_load_1and50yrsFtx_1y');
    end
    if Fty_1y_max<0
        error('ty_1y_max0Hydro_load_1and50yrsFty_1y_max');
    end
    if Ftz_1y_max<0
        error('tz_1y_max0Hydro_load_1and50yrsFtz_1y_max');
    end
    if Mtx_1y_max<0
        error('tx_1y_max0Hydro_load_1and50yrsMtx_1y_max');
    end
end
F1ND=Ftx_1y_max;
M1ND=Mtz_1y_max;
F1=DAF1*F1ND;%鍩轰簬鍔ㄦ€佹斁澶х郴鏁帮紝1骞存瀬绔�娴峰喌涓嬪�肩�℃灦鍙楃殑鍔�
M1=DAF1*M1ND;%鍩轰簬鍔ㄦ€佹斁澶х郴鏁帮紝1骞存瀬绔�娴峰喌涓嬪�肩�℃灦鍙楃殑鍔涚煩

% 搴旇�ュ厛璁惧畾娉㈡氮鍙傛暟銆佺劧鍚庡啀璁＄畻鑽疯浇
Wave.T=Tm2;%鏋佺��娉㈤珮鐨勫懆鏈�
Wave.h=Hm2;%鏋佺��娉㈤珮
Wave.k=wave_number(Wave.T,Wave.h);%娉㈡暟
[Ftx_2,Fty_2,Ftz_2,Mtx_2,Mtz_2,t]=Hydro_load_timehistory(t0,t1,dt,Member_group,y0_position);
[Ftx_2_max,Fty_2_max,Ftz_2_max,Mtx_2_max,Mtz_2_max]=Hydro_load_max(Ftx_2,Fty_2,Ftz_2,Mtx_2,Mtz_2);

if debug==1
    if size(Ftx_2)~=size(t)
        error('tx_2Hydro_load_1and50yrsFtx_2');
    end
    if Fty_2_max<0
        error('ty_2_max0Hydro_load_1and50yrsFty_2_max');
    end
    if Ftz_2_max<0
        error('tz_2_max0Hydro_load_1and50yrsFtz_2_max');
    end
    if Mtx_2_max<0
        error('tx_2_max0Hydro_load_1and50yrsMtx_2_max');
    end
end
F2ND=Ftx_2_max;
M2ND=Mtz_2_max;
F2=DAF2*F2ND;
M2=DAF2*M2ND;
end
