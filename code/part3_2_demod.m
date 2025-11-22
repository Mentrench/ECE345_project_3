%% ECE 345 – Project 3.2 Analog Demodulation (NO AUDIO)
% Uses golden.wav and upconvert.m from 3.1

clear; clc; close all;

%% -------- Load message m(t) again (same as before) --------

[rawAudio, fs] = audioread('golden.wav');   % stereo
m = rawAudio(:,1);                          % left channel
t_base = (0:length(m)-1) / fs;

%% -------- Upconvert to get s(t) at RF (reuse from 3.1) --------

fs_base = fs;           
fh      = 10e6;         
fc      = 1310e3;       
Gc      = 10;           

[s, mRF, tRF] = upconvert(m, Gc, fs_base, fc, fh);

Nrf = length(s);

%% -------- Generate noisy received signals --------

sigma2_low  = 0.01;
sigma2_high = 1.0;

w_low  = randn(1, Nrf);
w_high = randn(1, Nrf);

noise_low  = sqrt(sigma2_low)  .* w_low;
noise_high = sqrt(sigma2_high) .* w_high;

y_low  = s + noise_low;
y_high = s + noise_high;

%% -------- 3.2(a): Multiply by oscillator --------

osc = cos(2*pi*fc*tRF);

v_low  = y_low  .* osc;
v_high = y_high .* osc;

Nplot = min(5000, length(v_low));

figure;
subplot(3,1,1);
plot(tRF(1:Nplot), v_low(1:Nplot));
xlabel('Time (s)'); ylabel('Amplitude');
title('v(t) with \sigma^2 = 0.01');
grid on;

subplot(3,1,2);
plot(tRF(1:Nplot), v_high(1:Nplot));
xlabel('Time (s)'); ylabel('Amplitude');
title('v(t) with \sigma^2 = 1.0');
grid on;

subplot(3,1,3);
plot(t_base(1:min(2000,end)), m(1:min(2000,end)));
xlabel('Time (s)'); ylabel('Amplitude');
title('Original m(t)');
grid on;

%% -------- 3.2(b): Lowpass filter --------

fpass = fs/2;

vLP_low  = lowpass(v_low,  fpass, fh);
vLP_high = lowpass(v_high, fpass, fh);

figure;
subplot(2,1,1);
plot(tRF(1:Nplot), vLP_low(1:Nplot));
xlabel('Time (s)'); ylabel('Amplitude');
title('Lowpass v_{LP}(t) – \sigma^2 = 0.01');
grid on;

subplot(2,1,2);
plot(tRF(1:Nplot), vLP_high(1:Nplot));
xlabel('Time (s)'); ylabel('Amplitude');
title('Lowpass v_{LP}(t) – \sigma^2 = 1.0');
grid on;

%% -------- 3.2(c): Downconvert to fs --------

flow = fs/2;

mhat_low  = downconvert(y_low,  fh, fc, flow, fs);
mhat_high = downconvert(y_high, fh, fc, flow, fs);

t_mhat_low  = (0:length(mhat_low)-1)  / fs;
t_mhat_high = (0:length(mhat_high)-1) / fs;

figure;
subplot(2,1,1);
plot(t_base, m);
xlabel('Time (s)'); ylabel('Amplitude');
title('Original m(t)');
grid on;

subplot(2,1,2);
plot(t_mhat_low, mhat_low);
xlabel('Time (s)'); ylabel('Amplitude');
title('Reconstructed $\hat{m}(t)$, $\sigma^2 = 0.01$', 'Interpreter', 'latex')
grid on;

figure;
subplot(2,1,1);
plot(t_base, m);
xlabel('Time (s)'); ylabel('Amplitude');
title('Original m(t)');
grid on;

subplot(2,1,2);
plot(t_mhat_high, mhat_high);
xlabel('Time (s)'); ylabel('Amplitude');
title('Reconstructed $\hat{m}(t)$, $\sigma^2 = 1.0$', 'Interpreter', 'latex')
grid on;

disp('Finished 3.2(a), (b), and (c) – No audio playback included.');
