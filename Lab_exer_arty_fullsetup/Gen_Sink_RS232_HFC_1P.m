%%
%      ������������ ������������� ���������
%      ����������� 2015
%
%      ������ Gen_Sink_RS232_HFC_1P.m
%
%       ��������� �����������, ����������� ��� ������� ���������� ���� RS232 port 
%       �� ������ ����.  � ���������� ����� ������������ ����������������.
%       �� ���������� ��� ������������ ������������� ��� array  TxChars.
%       O� ���������� ��� ����������� ������������� ��� array  RxChars.
%
%       ��� Command Window  ��������� �������� ����������� ��� ��� ���������  ��� ����������
%       ��� ����� ������� �� ������� ������ ��� � ��������� ������/������ ���������.
%
%       ��� �� ������� ��� ��������� ���  ������������, �������    Ctrl-C
%       ��� ���� ������ �� ���������� �  ������  fclose(s1); clear s1;  ��� Command Window .
%
%
clear all;
close all;
clc;

disp('Starting the Characters Gen/Sink Application . . . . ');

Nc = 100;           %  ������ ���������� ���� ��������/����
Nstart = 0;         %  ������� ����� ���������� ���� ��������
Nend = 255;
pr_off = 0.1;       %  ���������� ��������������� �����

disptime = 2;       %  ������ ���������� (secs)
Nbuffer = 1;        % Tx/Rx buffer length

load('embeddedlab_data.mat');
load('embeddedlab_data1.mat');
TxChars = TxChars_user1;

RxChars = uint8(zeros(1, Nc));

%%
disp('Opening the RS232 port . . . . . ');
s1 = serial('COM7','BaudRate',9600,'Parity','none', 'Terminator', '');
set(s1, 'FlowControl', 'none');
set(s1, 'InputBufferSize', Nbuffer);
set(s1, 'OutputBufferSize', Nbuffer);
fopen(s1)
s1.RecordDetail = 'verbose';
s1.RecordName = 'S1.txt';
record(s1,'on')
disp('RS232 port activated');
disp(' ');


%%
tstart = clock;
tinit = tstart;

cnt_t = 0;
cnt_r = 0;
while cnt_t < Nc || cnt_r < Nc
    arv = s1.PinStatus.ClearToSend;      %  Check if Sink is ON  and the output buffer empty
    if length(arv) == 2  && s1.BytesToOutput < Nbuffer && cnt_t < Nc
        cnt_t = cnt_t + 1;          % generate new character
        fwrite(s1,TxChars(cnt_t));
    end
    
    %  Deactivate or activate the receiver
    deactpr = rand(1,1);
    if deactpr <= pr_off
        s1.RequestToSend = 'off';        %  Disable RTS (Rx OFF)
    else
        s1.RequestToSend = 'on';         %  Enable RTS (Rx ON)
        len = s1.BytesAvailable;    % wait to receive a new character
        if len ~= 0
            cnt_r = cnt_r + 1; 
            RxChars(cnt_r) = fread(s1,1);
        end
    end 

    timedif = etime(clock, tstart);         %  Update results
    if timedif > disptime
        fprintf('\n  Outgoing Characters: %d  of %d  ', cnt_t, Nc);
        fprintf('\n  Incoming Characters: %d  of %d \n', cnt_r, Nc);
        tstart = clock;
    end

end

timedif = etime(clock, tinit);      %  Total time

%%
disp(' ');
disp('Closing the RS232 port . . . . . ');
record(s1,'off')
fclose(s1)
delete(s1)
clear s1
disp('RS232 port deactivated');

disp(' ');
if TxChars_user2 == RxChars
    disp('Correct Data Transmission');
else
    disp('Incorrect Data Transmission');
    fprintf('\nCharacter Error Ratio =  %6.5f', sum(TxChars ~= RxChars)/Nc);
end
fprintf('\nCharacters exchanged: %d\nTime elapsed: %4.3f secs\nData rate: %4.3f Bps  \n\n', Nc, timedif, Nc/timedif);
disp(' . . . .  Ending the Characters Gen/Sink Application.');
