function [p_wt_1mw,p_pv_1mw,load] = wind_pv_load()
%读取风速，光照辐射，温度，负荷等已知信息
[wind_speed,rad,T_ae,load] = known_inf(); 

%风机参数
v_in = 3; %切入风速为3m/s
v_rated = 12;%额定风速为12m/s
v_out = 24;%切出风速为24m/s
% 我们假设 风机额定功率即为装机容量
% 因此当风机装机容量为1MW时，我们有：
for i = 1:24 %对于每个小时而言
    %若该时刻风速小于切入风速则
    if wind_speed(i,1) < v_in 
        p_wt_1mw(i,1) = 0; 
    end
    %若该时刻风速大于切入风速，且小于额定风速则
    if (wind_speed(i,1) >= v_in) && (wind_speed(i,1) <= v_rated) 
        p_wt_1mw(i,1) = 1*(wind_speed(i,1)^3-v_in^3)/(v_rated^3-v_in^3);
    end
    %若该时刻风速大于额定风速，且小于切出风速则
    if (wind_speed(i,1) > v_rated) && (wind_speed(i,1) <= v_out)
        p_wt_1mw(i,1) = 1;
    end
    %若该时刻风速大于切出风速则
    if (wind_speed(i,1) > v_out)
        p_wt_1mw(i,1) = 0;
    end
end
figure()
plot(p_wt_1mw,'Marker','+')
xlabel('时刻');
ylabel('1MW风机实际出力(MW)')

%光伏参数
I_sc = 8.63; %短路电流 A
I_pm = 8.15; %峰值电流 A
R_rated = 1000; %额定光照辐射 W/cm2
V_pm = 30.7; %峰值电压 V
T_rated = 25; %额定温度 30°C
f_s = 0.98; %灰尘修正系数

I_pv = max( I_sc * (rad/R_rated-1) +I_pm, 0); %实时电流 A
V_pv = max( V_pm * (1+0.0593*log(rad/R_rated)), 0); %实时电压 V
T_real = T_ae + 30*rad/800; %光伏面板实时温度 °C
f_T = 1 - (T_real-T_rated)/200; %温度修正系数
P_pv_rated = I_pm*V_pm; %1个pv的额定容量 W
P_pv_1 = I_pv .* V_pv .* f_T .* f_s; %1个pv在该光资源环境下的实时出力 W
p_pv_1mw = P_pv_1/P_pv_rated; %1MW pv的实时出力 MW
figure()
plot(p_pv_1mw,'Marker','+','Color','red')
xlabel('时刻');
ylabel('1MW光伏实际出力(MW)')
end