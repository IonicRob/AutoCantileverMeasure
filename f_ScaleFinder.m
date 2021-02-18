%% f_ScaleFinder

function OutPutCell = f_ScaleFinder(filename,waittime)
    % Gets image information
    info = imfinfo(filename);
    
    % Loads image in as a table
    Matrix = readtable(filename,'FileType','text','ReadVariableNames',false);
    ImageTable = table2cell(Matrix);
    clear Matrix
    
    % Tries to search for Image Pixel Size tag stored in Zeiss tif image
    % files.
    row_IPS = strcmp(ImageTable(:,1),'Image Pixel Size');
    if sum(row_IPS) % If that tag can be found it does the following.
        IPS = sprintf('%s/pixel',string(ImageTable(row_IPS==1,2)));
        IPS_Value = extractBefore(IPS,' ');
        IPS_Value =  str2double(IPS_Value);
        IPS_Unit = extractAfter(IPS,' ');
        IPSUnit_Num = extractBefore(IPS_Unit,'/');
        IPSUnit_Den = extractAfter(IPS_Unit,'/');
    elseif isfield(info,'XResolution') % If the tag CANNOT be found it does the following.
        IPS_Value = (info.XResolution/10^4)^-1;
        IPSUnit_Num = 'um';
        IPSUnit_Den = 'pixel';
    else
        warndlg('Code cannot interpret metadata');
    end
    
    % This is used to confirm to the user what the image's scale is
    message = sprintf('Scale for ImageJ = %s %s/%s\nOR %s %s/%s\n',string(1/IPS_Value),IPSUnit_Den,IPSUnit_Num,string(IPS_Value),IPSUnit_Num,IPSUnit_Den);
    disp(message);
    f = msgbox(message,'Output','help');
    popup(waittime,f)
    
    a_IPS_Value = IPS_Value;
    a_IPS_Unit = sprintf('%s/%s',IPSUnit_Num,IPSUnit_Den);
    
    NumberOfValues = 1;
    
    % If the image's scale will produce something like a scale bar of over
    % 1000 in units, then it does this alternative scale which then means
    % it should be < 1000 in the new units.
    if 1/IPS_Value < 1
        fprintf('___ALTERNATIVE___\n');
        first_value = (1/IPS_Value)*10^3;
        second_value = 1/((1/IPS_Value)*10^3);
        message = sprintf('Scale for ImageJ = %s %s/(%s*10^3)\nOR %s (%s*10^3)/%s\n',string(first_value),IPSUnit_Den,IPSUnit_Num,string(second_value),IPSUnit_Num,IPSUnit_Den);
        disp(message);
        f = msgbox(message,'Output','help');
        popup(waittime,f)
        NumberOfValues = 2;
        b_IPS_Value = second_value;
        b_IPS_Unit = sprintf('%s*10^3/%s',IPSUnit_Num,IPSUnit_Den);
    end
    
    OutPutCell = cell(NumberOfValues,2);
    OutPutCell{1,1} = a_IPS_Value;
    OutPutCell{1,2} = a_IPS_Unit;
    
    if NumberOfValues == 2
        OutPutCell{2,1} = b_IPS_Value;
        OutPutCell{2,2} = b_IPS_Unit;
    end
    
end

%% Other Functions

function popup(waittime,f)
    pause(waittime);
    try
        close(f);
    catch
        fprintf('Pop up already closed\n')
    end
end