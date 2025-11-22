%% ECE 345 – Project 3.3 Digital Modulation (4-QAM)

clear; clc; close all;

% Given parameters
fs = 44.1e3;     % Hz
A  = 200;        % energy parameter
K  = 4;          % cycles per symbol
f0 = 5e3;        % Hz

%% -------- 3.3(a): Plot QAM waveforms for 4 bit pairs --------

T_sym = K / f0;
N_sym = round(T_sym * fs);
T_sym = N_sym / fs;
t_sym = (0:N_sym-1) / fs;

a = sqrt(A/2);             % amplitude for each dimension
cos_p = cos(2*pi*f0*t_sym);
sin_p = sin(2*pi*f0*t_sym);

% Define all 4 bit pairs
pairs = [0 0;
         0 1;
         1 0;
         1 1];

figure;
for i = 1:4
    b1 = pairs(i,1);
    b2 = pairs(i,2);

    a_c = (2*b1 - 1) * a;      % 0->-a, 1->+a
    a_s = (2*b2 - 1) * a;

    s = a_c * cos_p + a_s * sin_p;

    subplot(4,1,i);
    plot(t_sym, s);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['QAM waveform for bits [' num2str(b1) ' ' num2str(b2) ']']);
    grid on;
end


%% -------- 3.3(b): Use QAMmod with the given bit string M --------

M = [0 0 1 1 0 1 0 1 1 0 0 1 1 0 0 1];   % 8 symbols, 16 bits

x = QAMmod(M, f0, A, K, fs);

t = (0:length(x)-1) / fs;

figure;
plot(t, x);
xlabel('Time (s)');
ylabel('Amplitude');
title('QAMmod output for bit sequence M');
grid on;

% Bit rate = (number of bits) / (total time)
totalTime = length(x) / fs;
bitRate   = length(M) / totalTime;
disp(['Bit rate for this signal: ' num2str(bitRate) ' bits/s']);


%% -------- 3.3(c): Encode "HELLOWORLD" using 7-bit ASCII + QAMmod --------

msg = 'HELLOWORLD';

% 7-bit ASCII binary strings (each row: one character)
binChars = dec2bin(msg);      % size: [numChars x 7]

% Convert to numeric bits and flatten into row vector
bitsMatrix = binChars.' - '0';    % transpose then char->0/1 numeric
bitsHELLO = bitsMatrix(:).';     % row vector length 70

% Modulate
xHELLO = QAMmod(bitsHELLO, f0, A, K, fs);

tHELLO = (0:length(xHELLO)-1) / fs;

figure;
plot(tHELLO, xHELLO);
xlabel('Time (s)');
ylabel('Amplitude');
title('Digitally modulated "HELLOWORLD" QAM signal');
grid on;


%% -------- 3.3(d): Test QAMdemod by decoding "HELLOWORLD" --------

bitsHat = QAMdemod(xHELLO, fs, f0, K);

% Reshape back into 7-bit words
numChars = length(bitsHELLO) / 7;
bitsMatHat = reshape(bitsHat, 7, numChars).';

% Convert bits -> '0'/'1' chars -> decimal -> char
charArray = char(bin2dec(char(bitsMatHat + '0'))).';

disp('Original message:');
disp(msg);

disp('Decoded message from QAMdemod:');
disp(charArray);
