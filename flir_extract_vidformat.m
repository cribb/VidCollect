function FormatInfo = flir_extract_vidformat(VidFormat)
    mytokens = regexpi(VidFormat, '(F7_|)(Raw|Mono)(\d*)_(\d+)x(\d+)(_Mode\d*|)', 'tokens');
    mytokens = mytokens{1};
    mytokens = cellfun(@(s)strrep(s, '_', ''), mytokens, 'UniformOutput', false);
    
    FormatInfo.ImageType = mytokens{2};
    FormatInfo.Height = str2double(mytokens{5});
    FormatInfo.Width = str2double(mytokens{4});
    FormatInfo.Depth = str2double(mytokens{3});
    FormatInfo.Mode = mytokens{6};        
return
