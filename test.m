input = 5;
target = 4;

wObj=waveFile2obj('cut.wav');
opt=pitchShift('defaultOpt');
opt.method='wsola';
opt.pitchShiftAmount = log2(target/input) * 12;
wObj2=pitchShift(wObj, opt, 1);
%[n,d] = rat(2);
wObj2.signal = resample(wObj2.signal, target, input);
audiowrite('cut_double.wav', wObj2.signal, wObj.fs);