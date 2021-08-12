%%%%%%% made by Jungmin Yoon %%%%%%%%%%%
%%%%%%%%  WuR-RIS(ver.2) 21.06.01 %%%%%%%% 

clear;
clc;
close all;
W=32;
m=3;

Packet_Payload=8184; 
MAC_hdr=272;
PHY_hdr=128;
Data=Packet_Payload+MAC_hdr+PHY_hdr; %Data bit size

ACK=112+PHY_hdr;
RTS=160+PHY_hdr;
CTS=112+PHY_hdr;
CTS_Timeout=300; 

Wake_Up= CTS;

RIS_Control=CTS; %RIS 제어 message
RIS_Unmodulated=CTS;  %AP가 RIS로 unmodulated 신호 전송, Wake_up+각 time slot modulate

Propagation_Delay=1;  %주어진 시간 변수
Slot_Time=50;
SIFS=28;
DIFS=128;
ACK_Timeout=300;

Station_Num=25:25:300;
Persentage=[20,50,80];

Total_Time_c=zeros(length(Persentage),length(Station_Num));    %Conventional WuR 전체 소요 시간
Total_Time_p=zeros(length(Persentage),length(Station_Num));    %Proposed WuR 전체 소요 시간


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Conventional WuR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iter=1:1000
    for station_c=1:length(Station_Num)
        for persentage_c=1:length(Persentage)
            Wanted_Signal_Num_c=Station_Num(station_c)*(Persentage(persentage_c)/100);
            backoff=randi([0,W-1],[1,ceil(Wanted_Signal_Num_c)]); 
            CWcase=ones(1,ceil(Wanted_Signal_Num_c));

            while sum(backoff)~=0   %station 개수만큼 반복
                min_backoff=min(backoff);
                backoff=backoff-min_backoff;
                Total_Time_c(persentage_c,station_c)=Total_Time_c(persentage_c,station_c)+DIFS+min_backoff*Slot_Time;

                if  nnz(backoff==0)>1 %충돌 나는 경우 backoff 0의 개수가 2 이상일때
                    col_case=find(backoff==0); %find: 조건에 맞는 숫자의 위치 정보 배열로 저장

                    for i=1:length(col_case)
                        if CWcase(col_case(i))<m
                            backoff(col_case(i))=randi([0, W*2^(CWcase(col_case(i)))-1]);
                            CWcase(col_case(i))=CWcase(col_case(i))+1;
                        else
                            backoff(col_case(i))=randi([0,W*2^(CWcase(col_case(i)))-1]);
                        end
                        Total_Time_c(persentage_c,station_c)=Total_Time_c(persentage_c,station_c)+RTS+Propagation_Delay;
                    end
                else %충돌 안난 경우- AP가 단말의 데이터 수신
                    CWcase(backoff==0)=[];
                    backoff(backoff==0)=[];
                    Total_Time_c(persentage_c,station_c)=Total_Time_c(persentage_c,station_c)+(Wake_Up+Propagation_Delay)+(RTS+Propagation_Delay)+SIFS+(CTS+Propagation_Delay)+SIFS+(Data+Propagation_Delay)+SIFS+(ACK+Propagation_Delay);
                end
            end
        end
    end
end
Total_Time_c_mean=Total_Time_c/1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Proposed WuR-RIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for station_p=1:length(Station_Num)
    for persentage_p=1:length(Persentage)
        Wanted_Signal_Num_p=Station_Num(station_p)*(Persentage(persentage_p)/100);
        if rem(Wanted_Signal_Num_p,4)==0 %단말의 개수가 4의 배수가 일 때 
            iter=0;
            while iter<ceil(Wanted_Signal_Num_p/4)
                Total_Time_p(persentage_p,station_p)=Total_Time_p(persentage_p,station_p)+(RIS_Control+Propagation_Delay)+SIFS+(RIS_Unmodulated+Propagation_Delay)+SIFS+(Data+Propagation_Delay+SIFS*2+ACK)*4;
                iter=iter+1;
            end
        else
            Total_Time_p(persentage_p,station_p)=((RIS_Control+Propagation_Delay)+SIFS+(RIS_Unmodulated+Propagation_Delay)+SIFS+(Data+Propagation_Delay+SIFS)*4)*fix(Wanted_Signal_Num_p/4)+((RIS_Control+Propagation_Delay)+SIFS+RIS_Unmodulated+Propagation_Delay)+SIFS+(Data+Propagation_Delay+SIFS)*rem(Wanted_Signal_Num_p,4);
        end
    end
end

figure
hold on; grid on;
plot(Station_Num,Total_Time_c_mean(3,:)/(10^6),'-^b');
plot(Station_Num,Total_Time_c_mean(2,:)/(10^6),'-xb');
plot(Station_Num,Total_Time_c_mean(1,:)/(10^6),'-ob');
plot(Station_Num,Total_Time_p(3,:)/(10^6),'-^r');
plot(Station_Num,Total_Time_p(2,:)/(10^6),'-xr');
plot(Station_Num,Total_Time_p(1,:)/(10^6),'-or');

xlabel('Number of Devices');
ylabel('Time Delay(s)');
legend('Conventional WuR, 선택 단말 비율=80%','Conventional WuR, 선택 단말 비율=50%','Conventional WuR, 선택 단말 비율=20%','WuR-RIS, 선택 단말 비율=80%','WuR-RIS, 선택 단말 비율=50%','WuR-RIS, 선택 단말 비율=20%')
















