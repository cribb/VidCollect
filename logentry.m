function logentry(txt)
% function for writing out stderr log messages

logtime = clock;
    
    % dbstack pulls the stack of function calls that got us here
    [stk,I] = dbstack;
    
    % This function is stk(1).name and its calling function is stk(2).name
    calling_func = stk(2).name;
    
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext calling_func ': '];
     
     fprintf('%s%s\n', headertext, txt);
    