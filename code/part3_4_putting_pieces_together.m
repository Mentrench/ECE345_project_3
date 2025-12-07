%% ECE 345 – Project 3.4 Putting the pieces together
% This script assumes you already have:
%   QAMmod.m, QAMdemod.m, upconvert.m, downconvert.m
% in your MATLAB path.

%% ---------------- Parameters ----------------

fs      = 44.1e3;      % baseband sampling frequency (Hz)
fh      = 10e6;        % RF simulation sampling frequency (Hz)
f0      = 5e3;         % QAM pulse frequency (Hz)
A       = 200;         % QAM energy parameter
Gc      = 10;          % carrier gain
K       = 4;           % cycles per baseband QAM pulse
fc      = 1310e3;      % carrier frequency (Hz)
fcutoff = fs/2;        % lowpass cutoff at downconversion

%% 3.4(a) – Build bit message from ASCII text and modulate with QAMmod

% Choose message with even number of characters
msg = 'I NEED TO FIND A BETTER SIGNAL';   % 30 characters (even)

% Convert chars -> 7-bit ASCII -> bits
binChars   = dec2bin(msg);        % each row is 7 chars '0'/'1'
bitsMatrix = binChars.' - '0';    % numeric 0/1, now 7 x numChars
M          = bitsMatrix(:).';     % row vector of bits

% Sanity check: number of bits, must be even for 4-QAM
if mod(length(M), 2) ~= 0
    error('Total number of bits must be even.');
end

disp(['Message: ', msg]);
disp(['Total bits: ', num2str(length(M))]);

% QAM modulation -> baseband message waveform m(t)
m_bb = QAMmod(M, f0, A, K, fs);   % row vector

% Check waveform length vs expected
T_sym   = K / f0;                       % symbol duration (s)
N_sym   = round(T_sym * fs);           % samples per symbol (as in QAMmod)
numSym  = length(M) / 2;
expectedLen = numSym * N_sym;

disp(['Length of m(t): ', num2str(length(m_bb))]);
disp(['Expected length: ', num2str(expectedLen)]);

% Time axis for baseband QAM waveform
t_bb = (0:length(m_bb)-1) / fs;

% Plot baseband QAM modulated signal m(t)
figure;
plot(t_bb, m_bb);
xlabel('Time (s)');
ylabel('Amplitude');
title('Baseband QAM message m(t)');
grid on;


%% 3.4(b) – Upconvert m(t) to passband x(t)

[x, mRF, tRF] = upconvert(m_bb, Gc, fs, fc, fh);  % x(t) at RF rate

% Plot a short slice of x(t) to see carrier
Nplot = min(5000, length(x));

figure;
plot(tRF(1:Nplot), x(1:Nplot));
xlabel('Time (s)');
ylabel('Amplitude');
title('Passband signal x(t) (zoomed segment)');
grid on;


%% 3.4(c) – Add noise to get y(t) = x(t) + w(t) with sigma^2 = 0.01

sigma2 = 0.01;
sigma  = sqrt(sigma2);

w = sigma * randn(1, length(x));  % Gaussian noise with variance sigma^2
y = x + w;

figure;
plot(tRF(1:Nplot), y(1:Nplot));
xlabel('Time (s)');
ylabel('Amplitude');
title(['Received passband y(t) with \sigma^2 = ', num2str(sigma2)]);
grid on;


%% 3.4(d) – Downconvert y(t) to baseband m_hat(t)

m_hat = downconvert(y, fh, fc, fcutoff, fs);  % row vector at fs
t_hat = (0:length(m_hat)-1) / fs;

figure;
subplot(2,1,1);
plot(t_bb, m_bb);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original baseband message m(t)');
grid on;

subplot(2,1,2);
plot(t_hat, m_hat);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recovered baseband $\hat{m}(t)$, $\sigma^2 = 0.01$', ...
      'Interpreter', 'latex');
grid on;


%% 3.4(e) – Demodulate with QAMdemod and compute bit errors

bitsHat = QAMdemod(m_hat, fs, f0, K);

% Align lengths just in case
Ntrue  = length(M);
Nhat   = length(bitsHat);
Ncomp  = min(Ntrue, Nhat);

bitErrors = sum(M(1:Ncomp) ~= bitsHat(1:Ncomp));
BER       = bitErrors / Ncomp;

disp('--- Single-run BER with \sigma^2 = 0.01 ---');
disp(['Compared bits: ', num2str(Ncomp)]);
disp(['Bit errors:    ', num2str(bitErrors)]);
disp(['Bit error rate: ', num2str(BER)]);

%% ECE 345 – Project 3.4 (f) & (g): Simulation and Plotting
clear; clc; close all;

%% 1. Parameters
fs      = 44.1e3;       % Baseband sampling frequency (Hz)
fh      = 10e6;         % RF simulation sampling frequency (Hz)
f0      = 5e3;          % QAM pulse frequency (Hz)
A       = 200;          % QAM energy parameter
Gc      = 10;           % Carrier gain
K       = 4;            % Cycles per baseband QAM pulse
fc      = 1310e3;       % Carrier frequency (Hz)
fcutoff = fs/2;         % Lowpass cutoff at downconversion

% Message Selection
msgStr = 'I NEED TO FIND A BETTER SIGNAL';
binChars = dec2bin(msgStr);          % Convert to char array of binary
bitsMatrix = binChars.' - '0';       % Convert to 0/1 integers
M = bitsMatrix(:).';                 % Flatten to row vector of bits

%% 2. Simulation Setup (CORRECTED RANGE)
% We adjust the range to where errors actually occur (1/sigma^2 from 10^3 to 10^7)
% This captures the "waterfall" curve seen in the sample report.
inv_sigma2_range = logspace(3, 7, 15); 
sigma2_range = 1 ./ inv_sigma2_range;   

numTrials = 100;                        % Increased trials to catch rare errors
BER_results = zeros(size(sigma2_range));

fprintf('Starting Simulation (%d trials per variance)...\n', numTrials);

%% 3. Main Simulation Loop
for i = 1:length(sigma2_range)
    sigma2 = sigma2_range(i);
    sigma = sqrt(sigma2);
    
    totalErrors = 0;
    totalBits = 0;
    
    for t = 1:numTrials
        % --- A. Modulate ---
        m_bb = QAMmod(M, f0, A, K, fs);
        
        % --- B. Upconvert ---
        [x, ~, ~] = upconvert(m_bb, Gc, fs, fc, fh);
        
        % --- C. Add Noise ---
        w = sigma * randn(1, length(x));
        y = x + w;
        
        % --- D. Downconvert ---
        m_hat = downconvert(y, fh, fc, fcutoff, fs);
        
        % --- E. Demodulate ---
        bitsHat = QAMdemod(m_hat, fs, f0, K);
        
        % Count Errors
        lenComp = min(length(M), length(bitsHat));
        bitErrors = sum(M(1:lenComp) ~= bitsHat(1:lenComp));
        
        totalErrors = totalErrors + bitErrors;
        totalBits = totalBits + lenComp;
    end
    
    BER_results(i) = totalErrors / totalBits;
    
    fprintf('1/sigma^2 = %.2e | Avg BER = %.5f\n', ...
            inv_sigma2_range(i), BER_results(i));
end

%% 4. Plotting (Part g)
% Plot log10(BER) vs log10(1/sigma^2)

log_inv_sigma2 = log10(inv_sigma2_range);
log_BER = log10(BER_results);

% --- PLOT FIX ---
% Only plot points where BER > 0 to avoid -Inf issues
valid_idx = BER_results > 0;

figure;
plot(log_inv_sigma2(valid_idx), log_BER(valid_idx), '-o', 'LineWidth', 2);
grid on;
xlabel('log_{10}(1 / \sigma^2) (Proxy for SNR)');
ylabel('log_{10}(Bit Error Rate)');
title(['BER vs SNR Proxy (G_c = ' num2str(Gc) ')']);
subtitle('Corrected Range to visualize Error Waterfall');

% Set axis limits to match the report style
xlim([3 7]); 
ylim([-4 0]); % Adjust based on results

% Aesthetics matching the project report style
set(gca, 'FontSize', 12);
xlim([min(log_inv_sigma2) max(log_inv_sigma2)]);

disp('Simulation Complete.');