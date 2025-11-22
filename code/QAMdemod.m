function bitsHat = QAMdemod(m, fs, f0, K)
% QAMdemod  4-QAM demodulator using matched filters + conv
%   m      : received baseband signal (row or column vector)
%   fs     : sampling rate (Hz)
%   f0     : pulse frequency (Hz)
%   K      : number of cycles per symbol
%
%   bitsHat: row vector of estimated bits (0/1)

    % Ensure row vector
    m = m(:).';

    % Symbol duration and samples per symbol
    T_sym = K / f0;
    N_sym = round(T_sym * fs);
    T_sym = N_sym / fs;
    t_sym = (0:N_sym-1) / fs;

    % Basis pulses (no need for A here, just shapes)
    p_c = cos(2*pi*f0*t_sym);    % cosine basis
    p_s = sin(2*pi*f0*t_sym);    % sine basis

    % Matched filter impulse responses (time-reversed)
    h_c = fliplr(p_c);
    h_s = fliplr(p_s);

    % Number of whole symbols present
    numSym = floor(length(m) / N_sym);

    bitsHat = zeros(1, 2*numSym);

    for k = 1:numSym
        idxStart = (k-1)*N_sym + 1;
        idxEnd   = k*N_sym;

        xk = m(idxStart:idxEnd);   % one symbol chunk

        % Convolution approximating CT matched filtering
        yc = conv(xk, h_c) / fs;
        ys = conv(xk, h_s) / fs;

        % Sample at symbol time (full overlap index = N_sym)
        zc = yc(N_sym);
        zs = ys(N_sym);

        % Decision: >= 0 -> bit 1, < 0 -> bit 0
        bitsHat(2*k - 1) = zc >= 0;
        bitsHat(2*k)     = zs >= 0;
    end
end
