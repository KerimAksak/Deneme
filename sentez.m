close all
clear
clc

parse = parseMusicXML('muzik/nota.musicxml');%Muzik dosyasinin parse hali

%Tanimlamalar
fs=44100;
uzunluk=size(parse);
harmonikSayisi=5;
zarfSecimi=1;        %1=ADSR,0=Exponential
convOrReverb=1;      %1=reverb,0=conv
Normalizasyon=0;     %1=Normalizasyon Uygula, 0=Normalizasyon Uygulama**
calinanNota=[];

for i=1:uzunluk(1)
    frekans = note(parse(i,4));
    tt=0:1/fs:(parse(i,7));
    
    %Tanimlama
    notalar = zeros(size(tt));
    
    %------------------HARMONIK EKLEME-----------------------
    for j=1:harmonikSayisi
        notalar=notalar+(1/j)*cos(2*pi*j*frekans*tt);
    end
    %--------------------------------------------------------
    notalar = notalar(1:end-1);
    %------------------ZARFLAMA ISLEMI-----------------------
    if zarfSecimi == 1
        A=linspace(0, 1.5, floor(length(tt)*0.2)); 
        D=linspace(1.5, 1, floor(length(tt)*0.1));
        S=ones(1, floor(length(tt)*0.5)); 
        R=linspace(1, 0, floor(length(tt)*0.2)); 
        zarfADSR = [A D S R];
        zarfliNota=zarfADSR.*notalar;
    elseif zarfSecimi == 0
        zarfExponential = exp(-tt/parse(i,2));
        zarfExponential = zarfExponential(1:end-1);
        zarfliNota=zarfExponential.*notalar;    
    end
    %--------------------------------------------------------
 
    calinanNota = [calinanNota zarfliNota];
end

%-----------------NORMALÝZASYON------------------
if Normalizasyon == 1
    signalPeak = max(abs(calinanNota));
    calinanNota = (1/signalPeak)*calinanNota;
    
    figure('Name','Normalizasyon Islemi Gormus Sinyal','NumberTitle','off')
    plot(calinanNota)
    legend('Normalizasyon Sonrasý')
    grid
    hold on
end
%------------------------------------------------


%--------------SES DOSYALARI--------------------
%echosuz=audioplayer(calinanNota,fs);
%play(echosuz);
if convOrReverb == 1
    %reverb
    calinanNotaTers=(calinanNota)';
    reverb = reverberator('PreDelay',.15,'WetDryMix',.20)
    echoNota = reverb(calinanNotaTers);
    sound(echoNota,fs);
elseif convOrReverb == 0
    %conv
    h=[1,zeros(1,0.4*1000),0.5,zeros(1.0,0.4*1000),0.25];
    echoNota=conv(calinanNota,h);
    sound(echoNota,fs);
end
%------------------------------------------------

%---------------------PLOT-----------------------
figure('Name','Harmonik&Zarf','NumberTitle','off')
plot(calinanNota)
legend('Harmonik Ve Zarf Eklenmis Nota')
grid
hold on
figure('Name','Reverb','NumberTitle','off')
plot(echoNota)
legend('Echo Eklenmis Sinyal')
grid
hold on
%------------------------------------------------