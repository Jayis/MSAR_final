input = 5;
target = 3;

wObj=waveFile2obj('test.wav');
opt=pitchShift('defaultOpt');
opt.method='wsola';
opt.pitchShiftAmount = log2(target/input) * 12;
wObj2=pitchShift(wObj, opt, 1);
%[n,d] = rat(2);
wObj2.signal = resample(wObj2.signal, target, input);
audiowrite('test_out1.wav', wObj2.signal, wObj.fs);