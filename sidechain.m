%Sidechain compressor
%by Rob Salino


%*********************************************************
%TURN VOLUME DOWN - THE SYNTH IS VERY ABRASIVE IN THIS DEMO
%**********************************************************


clear all 
close all

%main signal to be compressed by other signal
main = 'main.wav';
[y_main,fs_main] = audioread(main);

%the "sidechain" or "key" signal, to change attack/release for the main
%signal to be compressed with
sidechain_input = 'sidechain.wav';
[y_side,fs_side] = audioread(sidechain_input);

%array of "y-axis" data at sample rate for each signal
y_main = y_main(:,1);
y_side = y_side(:,1);

%although the time should really be the same, will separate
t_main = 0:1/fs_main:length(y_main)/fs_main-1/fs_main;
t_side = 0:1/fs_side:length(y_side)/fs_side-1/fs_side;

%constant (DO NOT CHANGE)
TC = log(0.368);

%attack, release, threshold, and ratio are still adjustable independent of
%the sidechain input, hoping to set AT, RT, and Thresh to pots in the DSP
%board implementation and Ratio will be button that cycles through 1, 2, 4,
%8, 16, 20, 25
Attack_Time = 0.01;
Release_Time = 0.1;
Threshold = -20.0;
Ratio = 6.0;

%envelope for main
env_prev = 0;

%AT and RT set by sidechain data
AT = exp(TC/((Attack_Time * fs_main)));
RT = exp(TC/((Release_Time * fs_main)));

%rectify input signal
rect_y_main = (abs(y_main)).^2;

%rectify sidechain signal
rect_y_side = (abs(y_side)).^2;

%now to process the input signal as a result of the sidechain signal
%determining the detector parameters
for i=1:length(y_main)
    if(rect_y_main(i) > env_prev)
        env(i) = AT*(env_prev)+(1-AT)*rect_y_side(i);
    else
        env(i) = RT*(env_prev)+(1-RT)*rect_y_side(i);
    end
    
    if(env(i) < 0)
        env(i) = 0;
    end
    env_prev = env(i);
    env(i)= sqrt(env(i));
    
    if(env(i) <= 0)
        d(i) = -96;
    else
        d(i) = 20*log10(env(i));
    end
    
    if(d(i) <= Threshold)
        Gain_dB(i) = 0;
    else
        Gain_dB(i) = Threshold + ((d(i)-Threshold)/Ratio) - d(i);
    end
    
    %combo of the sidechain signal and the main signal that has been
    %compressed aroudn the sidechain signal (can remove y_side(i) to hear
    %what the output compressed around the sidechain sounds like)
    output_with_side(i) = (10.^(Gain_dB(i)/20)) * y_main(i) + y_side(i);
    output_without_side(i) = (10.^(Gain_dB(i)/20)) * y_main(i);

    %might add additional section to compress both after combining them,
    %since the combo clips
    
end


%(TO PLAY THE SIDECHAIN INPUT SIGNAL OR MAIN SIGNALS INDEPENDENTLY):
%sound(y_side,fs_side);
%sound(y_main,fs_main);



set(gcf, 'Position',  [100, 100, 800, 1400])
subplot(2,1,1), plot(t_main,y_main,t_main,y_side), legend('Main Signal','Sidechain Input')
xlabel('Time (s)'), ylabel('Amplitude'), title('Sidechain Signal Overlayed on Main Signal')

subplot(2,1,2), plot(t_main,output_without_side), xlabel('Time (s)'), ylabel('Amplitude')
title('Main Signal After Compression Without Kick Drum')
sound(output_without_side,fs_main);

%          (COMMENT OUT THE ABOVE OR THE BELOW PLOT AND SOUND FOR MAIN WITHOUT/WITH KICK DRUM)

%%subplot(2,1,2), plot(t_main,output_with_side), xlabel('Time (s)'), ylabel('Amplitude')
%%title('Main Signal "Sidechained" With Kick Drum')
%%sound(output_with_side,fs_main);

%for output file
len = length(output_with_side);
filename = 'output.wav';
audiowrite(filename,output_with_side,len)



%%For soft knee, just need to think about first period being linear (in/out
%%ratio), then threshold + some value, then the ratio I had after
%%inputs on separate channels - mixing both as mono to both L & R for
%%output