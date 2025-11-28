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


%% 3.4(f) – Monte Carlo: average BER vs sigma^2 (10 values, 50 runs each)

% Use log-spaced noise variances, e.g. from 1e-8 to 1e-2
sigma2_vals = logspace(-8, -2, 10);
avgBER      = zeros(size(sigma2_vals));

numRuns = 50;

for i = 1:length(sigma2_vals)
    sigma2_i = sigma2_vals(i);
    sigma_i  = sqrt(sigma2_i);

    totalErrors = 0;
    totalBits   = 0;

    for r = 1:numRuns
        % Upconvert same baseband m(t)
        [x_i, ~, ~] = upconvert(m_bb, Gc, fs, fc, fh);

        % Add noise with variance sigma2_i
        w_i = sigma_i * randn(1, length(x_i));
        y_i = x_i + w_i;

        % Downconvert
        m_hat_i = downconvert(y_i, fh, fc, fcutoff, fs);

        % Demodulate
        bitsHat_i = QAMdemod(m_hat_i, fs, f0, K);

        % Compare bits
        Ntrue_i = length(M);
        Nhat_i  = length(bitsHat_i);
        Ncomp_i = min(Ntrue_i, Nhat_i);

        err_i = sum(M(1:Ncomp_i) ~= bitsHat_i(1:Ncomp_i));

        totalErrors = totalErrors + err_i;
        totalBits   = totalBits   + Ncomp_i;
    end

    avgBER(i) = totalErrors / totalBits;
    disp(['sigma^2 = ', num2str(sigma2_i), ...
          ', avg BER = ', num2str(avgBER(i))]);
end

% Plot BER vs 1/sigma^2 using log-log scale
SNRproxy = Gc ./ sigma2_vals;   % Matches rubric: SNR = Gc / sigma^2    

figure;
loglog(SNRproxy, avgBER, 'o-');
xlabel('1 / \sigma^2 (proxy for SNR)');
ylabel('Average bit error rate');
title('BER vs 1/\sigma^2 for QAM over noisy AM channel');
grid on;

disp('Finished 3.4(a)–(f).');


%%PART G

%% Increasing the pulse frequency f0 makes the bit rate go up because symbols become shorter, but it also makes the bit error rate get worse because there is less energy per symbol. Increasing the energy parameter A, the number of cycles K, or the carrier gain Gc makes the bit error rate go down because the signal becomes stronger or longer and easier to detect. Increasing the noise variance sigma2 makes the bit error rate go up. Changing the carrier frequency fc does not have an important effect on the bit error rate. Only parameters that change symbol duration affect the transmission rate. Carrier frequency, energy, and noise do not change the transmission rate because they do not change how fast symbols are sent.
