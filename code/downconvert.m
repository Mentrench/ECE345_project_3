function mhat = downconvert(y, fh, fc, flow, fs)
% downconvert  Demodulate y(t) into baseband m̂(t) (row vector)

    y = y(:).';

    N = length(y);
    t = (0:N-1) / fh;

    osc = cos(2*pi*fc*t);
    v = y .* osc;

    vLP = lowpass(v, flow, fh);

    vLP_col = vLP.';
    mhat_col = resample(vLP_col, fs, fh);

    mhat = mhat_col.';
end
