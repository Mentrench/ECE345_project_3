%% ECE 345 – Project 3.1 (a), (b), (c)

%% ------------------ Part (a): Load, plot, listen, energy ------------------

% Load audio (stereo)
[rawAudio, fs] = audioread('golden.wav');

% Verify sampling rate
disp("Sampling rate fs = " + fs + " Hz");   % should be 44100

% Extract left channel as m(t)
m = rawAudio(:, 1);     % message signal m(t)

% Time axis for baseband signal
t = (0:length(m)-1) / fs;

% Plot m(t)
figure;
plot(t, m);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Message Signal m(t) from golden.wav');
grid on;

% Listen to clip
disp('Playing left channel (m(t))...');
soundsc(m, fs);

% Compute total energy of m(t) (approximate CT energy)
Em = sum(m.^2) * (1/fs);
disp("Total energy Em of m(t) = " + Em);


%% ------------------ Part (b): Upconvert to RF (AM 1310) ------------------

% Baseband sampling rate:
fs_base = fs;                % 44.1 kHz

% RF simulation sampling rate:
fh = 10e6;                   % 10 MHz

% Carrier parameters
fc = 1310e3;                 % 1310 kHz
Gc = 10;                     % carrier gain

% Use upconvert() function to create passband signal s(t)
[s, mRF, tRF] = upconvert(m, Gc, fs_base, fc, fh);

% 1. Plot the upsampled version of m(t)
figure;
plot(tRF, mRF);
xlabel('Time (s)');
ylabel('Amplitude');
title('Upsampled Message Signal m(t) at f_h = 10 MHz');
grid on;

% 2. Compute energy of the upsampled m(t)
% We use 1/fh because the sample time dt = 1/fh
Em_upsampled = sum(mRF.^2) * (1/fh);
disp("Energy of upsampled m(t): " + Em_upsampled);

% Compare to original Em (which you calculated in Part A)
% Ensure Em is available here. If you ran Part A, it is in your workspace.
if exist('Em', 'var')
    disp("Difference from original Em: " + (Em_upsampled - Em));
end

% Plot a short segment of s(t) to see the carrier
Nplot = min(5000, length(s));        % only plot a small chunk
figure;
plot(tRF(1:Nplot), s(1:Nplot));
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Passband Signal s(t) (zoomed in)');
grid on;

% Compute energy of s(t)
Es = sum(s.^2) * (1/fh);
disp("Total energy Es of s(t) = " + Es);

% Energy ratio Es / Em for this Gc
ratio_single = Es / Em;
disp("Energy ratio Es/Em for Gc = " + Gc + " is " + ratio_single);


% Check dependence of Es/Em on Gc for a few values
Gc_values = [1 2 5 10];
ratio_vals = zeros(size(Gc_values));

for k = 1:length(Gc_values)
    Gc_k = Gc_values(k);
    [s_k, ~, ~] = upconvert(m, Gc_k, fs_base, fc, fh);
    Es_k = sum(s_k.^2) * (1/fh);
    ratio_vals(k) = Es_k / Em;
end

disp('Gc values:');
disp(Gc_values);
disp('Corresponding Es/Em ratios:');
disp(ratio_vals);


%% ------------------ Part (c): Add noise and form y(t) ------------------

% We will use the last s(t) we computed (with Gc = 10)
s_len = length(s);

% Define noise variances
sigma2_list = [0.01 0.1 1.0];

for i = 1:length(sigma2_list)
    sigma2 = sigma2_list(i);
    sigma  = sqrt(sigma2);

    % Generate white Gaussian noise w(t)
    w = randn(1, s_len);                 % mean 0, variance 1

    % Scale noise to have variance sigma^2
    noise = sigma * w;

    % Received signal y(t) = s(t) + noise
    y = s + noise;

    % Plot compare s(t) and y(t) (small segment for visibility)
    figure;
    subplot(2,1,1);
    plot(tRF(1:Nplot), s(1:Nplot));
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(['Clean s(t), Gc=10']);

    subplot(2,1,2);
    plot(tRF(1:Nplot), y(1:Nplot));
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(['Noisy y(t) with \sigma^2 = ' num2str(sigma2)]);
end

% [Inside Part (c) of part3_1.m]

for i = 1:length(sigma2_list)
    sigma2 = sigma2_list(i);
    sigma  = sqrt(sigma2);

    % Generate white Gaussian noise w(t)
    w = randn(1, s_len);

    % Scale noise to have variance sigma^2
    noise = sigma * w;

    % Received signal y(t) = s(t) + noise
    y = s + noise;

    % --- NEW CODE: Calculate and Display Energy ---
    Ey = sum(y.^2) * (1/fh);
    disp(['Energy for sigma^2 = ', num2str(sigma2), ' is: ', num2str(Ey)]);
    % ---------------------------------------------

    % Plot compare s(t) and y(t)
    figure;
    subplot(2,1,1);
    plot(tRF(1:Nplot), s(1:Nplot));
    xlabel('Time (s)'); ylabel('Amplitude');
    title(['Clean s(t), Gc=10']);
    grid on;

    subplot(2,1,2);
    plot(tRF(1:Nplot), y(1:Nplot));
    xlabel('Time (s)'); ylabel('Amplitude');
    title(['Noisy y(t) with \sigma^2 = ' num2str(sigma2)]);
    grid on;
end

disp('Finished parts (a), (b), and (c).');

