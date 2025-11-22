function [s, mRF, tRF] = upconvert(m, Gc, fs, fc, fh)
% upconvert  Upconverts baseband message m(t) to RF passband s(t)
%   m   : baseband message (column or row vector) at sampling rate fs
%   Gc  : carrier gain
%   fs  : baseband sampling rate (e.g., 44.1 kHz)
%   fc  : carrier frequency (e.g., 1310 kHz)
%   fh  : RF simulation sampling rate (e.g., 10 MHz)
%
%   Outputs:
%   s   : passband signal at sampling rate fh (row vector)
%   mRF : resampled baseband message at rate fh
%   tRF : time axis for s and mRF

    % Ensure m is a column vector for resample
    m = m(:);

    % Resample from fs to fh
    mRF = resample(m, fh, fs);      % now mRF is at 10 MHz

    % Time axis for RF sampling
    N = length(mRF);
    tRF = (0:N-1) / fh;

    % Carrier signal
    c = Gc * cos(2*pi*fc*tRF);      % row vector

    % Make mRF a row vector to match c
    mRF_row = mRF.';                % transpose to row

    % Element-wise multiplication to get s(t)
    s = mRF_row .* c;               % row vector
end
