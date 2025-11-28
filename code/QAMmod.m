function x = QAMmod(M, f0, A, K, fs)
% QAMmod  4-QAM modulator
%   M  : row or column vector of bits (0/1), length must be even
%   f0 : pulse frequency (Hz), e.g. 5e3
%   A  : energy parameter, e.g. 200
%   K  : number of cycles per symbol, e.g. 4
%   fs : sampling rate (Hz), e.g. 44.1e3
%
%   x  : row vector, concatenation of all QAM waveforms

    % Ensure row vector
    M = M(:).';
    if mod(length(M), 2) ~= 0
        error('Length of M must be even (pairs of bits per symbol).');
    end

    % Symbol duration and samples per symbol
    T_sym   = K / f0;                  % T = K * (1/f0)
    N_sym   = round(T_sym * fs);       % samples per symbol
    T_sym   = N_sym / fs;              % adjust T to match integer samples
    t_sym   = (0:N_sym-1) / fs;        % time vector for one symbol

    % Basis functions
    a      = sqrt(A/2);                % amplitude for each component
    cos_p  = cos(2*pi*f0*t_sym);       % cosine pulse
    sin_p  = sin(2*pi*f0*t_sym);       % sine pulse

    % Number of QAM symbols
    numSym = length(M) / 2;

    % Preallocate full signal
    x = zeros(1, numSym * N_sym);

    for k = 1:numSym
        b1 = M(2*k - 1);   % first bit (cos)
        b2 = M(2*k);       % second bit (sin)

        % Map 0 -> -a, 1 -> +a
        a_c = (2*b1 - 1) * a;
        a_s = (2*b2 - 1) * a;

        % One symbol waveform
        symbol = a_c * cos_p + a_s * sin_p;

        % Insert into output
        idxStart = (k-1)*N_sym + 1;
        idxEnd   = k*N_sym;
        x(idxStart:idxEnd) = symbol;
    end
end
