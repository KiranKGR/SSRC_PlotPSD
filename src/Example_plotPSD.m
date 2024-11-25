%% The code is meant to act as a template for plotting a spectrogram. Please edit as necessary to generate accurate results pertinent to your case
clear all; clc;
warning off;
% defaults
set(0,'defaultAxesFontSize',24); % set the default axes font
set(0,'defaultAxesFontName','Calibri')
set(0,'defaultLineLineWidth',1.5);   % set the default line width to lw
set(0,'defaultAxesFontName','Calibri')
set(0,'defaultAxesTickDir','out');
% hypnogram dictionary
Hypnogram_dictionary = dictionary(["N3","N2","N1","R","W","A"],[1,2,3,4,5,6]);
%% Import and assign data
Hypnogram_data=readtable("..\exampledata\Hypnogram.xlsx","Sheet","Hypnogram");
Hypnogram_Time= datetime(Hypnogram_data.EpochTime);
Hypnogram= Hypnogram_dictionary(string(Hypnogram_data.SleepStage));
LightsOff=datetime(erase(Hypnogram_data.Markers{1},'LightsOff: '));
LightsOn=datetime(erase(Hypnogram_data.Markers{2},'LightsOn: '));
%% Import Example recording with F4M1
% Get Hypnogram and markers
% Get EEG data- Segment it and Get PSD
Data=edfread("..\exampledata\Recording.edf",'TimeOutputType','datetime');
time_temp=Data.("Record Time");
sec_num=seconds(time_temp(2)-time_temp(1));
Variab_names=string(Data.Properties.VariableNames);
Fs=length(Data.(1){1})/sec_num;
% Truncate the top of the Data to the start of the hypnogram
start_sec=seconds(Hypnogram_Time(1)-time_temp(1));
Data(1:(start_sec),:)=[];
%% This section needs to be debugged. Please identify the errors and fix it to get the accurate result. 
% FFT details
epoch=10; % 10 segments of 4 s sub epochs
% the recording has one second records
% create the PSD - 30 s epoch divided into 10 segments (4 seconds data with one second overlap)
L=4*Fs;
NFFT=2^nextpow2(L);
f_vector=Fs*(0:(NFFT/2))/NFFT;
Lp=(0.3/(Fs/2)); Hp=(20/(Fs/2));
[b,a] = butter(3,[Lp Hp],'bandpass');
Spectrum=nan(length(f_vector),(length(Hypnogram)));
for iloop=1:length(Hypnogram)
    [P3, ~] = pwelch(filtfilt(b,a,reshape([Data.(1){((iloop-1)*30)+1:iloop*30}],[],1)),hanning(L),Fs,NFFT);
    Spectrum(:,iloop)=P3/epoch; % Power divided by the number of sub-epochs 
end
%% Prepare the data
% hypnogram time vector
% evenly samply at 30 s intervals
In.Hypnogram_Time=Hypnogram_Time;
% hypnogram
% contains the sleep stage timecourse mapped using the dictionary at the
% top of the code
In.Hypnogram=Hypnogram;
% contains the spectrogram - rows are the power per freq. and columns are
% the epochs
In.Spectrum=Spectrum;
% frequency vector
In.f_vector=f_vector;
% Lights off and on Markers
In.LightsOff=LightsOff;
In.LightsOn=LightsOn;
In.SWAthreshold=7000;
%% Plot the data
PlotPSD(In)
