function mhat = downconvert(y, fh, fc, flow, fs)
% downconvert  Demodulates y(t) into baseband m̂(t)
%   y    : received RF signal (column or row vector) at sampling rate fh
%   fh   : RF sampling rate (e.g., 10 MHz)
%   fc   : carrier frequency (e.g., 1310 kHz)
%   flow : cutoff frequency for lowpass filter (e.g., 3 kHz)
%   fs   : baseband sampling rate (e.g., 44.1 kHz)
%
%   Outputs:
%   mhat : demodulated baseband signal (row vector)

    % Ensure y is a row vector
    y = y(:).';

    % Length of the input signal
    N = length(y);
    t = (0:N-1) / fh;

    % Generate the local oscillator
    osc = cos(2*pi*fc*t);
    v = y .* osc;  % Mix the signal with the oscillator

    % Lowpass filter the mixed signal
    vLP = lowpass(v, flow, fh);

    % Resample the lowpass filtered signal to baseband rate
    vLP_col = vLP.';
    mhat_col = resample(vLP_col, fs, fh);

    % Ensure output is a row vector
    mhat = mhat_col.';
end
