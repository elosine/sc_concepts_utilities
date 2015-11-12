(
~audioSettings = {
        var data = "system_profiler SPAudioDataType".unixCmdGetStdOut;
        var outputIndex, inputIndex, inputResult, outputResult, offset;

        data = data.split(Char.nl);
        data.do{|x, i|
                if(x.contains("Default Input Device: Yes"), {inputIndex = i-1});
                if(x.contains("Default Output Device: Yes"), {outputIndex = i-2});
        };
        if(outputIndex-inputIndex == 1, {offset = 1}, {offset = 0});
        inputResult = data[inputIndex].copyRange(8, data[inputIndex].size);
        outputResult = data[outputIndex-offset].copyRange(8, data[outputIndex-offset].size);
        [inputResult, outputResult];
};
)
~audioSettings.value[0]

d = "system_profiler SPAudioDataType".unixCmdGetStdOut;
d = d.split(Char.nl);
d.size