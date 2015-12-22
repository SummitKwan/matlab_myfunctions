%
% create and set a slider linked to a variable
% to call this function, run: myslider(parent_fig_handle,'para_name',para)
% eg.: myslider(gcf, 'name','X', 'dataname', 'X', ...
% 'position', [0.05,0.85,0.3,0.1], 'scale',[0,100],'rounded',1);
% 
% parameter list:
% 'name': the name of this slider
% 'position' : position in [left, bottom, width, height]
% 'dataobj' : the handle for the obj that contains data (default: parent_fig_handle)
% 'dataname' : the name of the varible being adjusted in dataobj
% 'scale' : the boundary of adjustable range [min, max]
% 'value' : initial value of the varible
% 'rounded' : only alow rounded number
% 'action' : the function to excecute once you change value
%
% writen by Shaobo Guan (Summit Kwan) at Jul 12, 2013
% contact: Shaobo_Guan@brown.edu

function  h_myslider = myslider(varargin)

numArgIn = length(varargin);

h_parent = gcf;
name = [];
position = [0.05,0.85,0.3,0.1];
scale = [0,1];
value = mean(scale);
rounded = false;
dataobj = h_parent;
dataname = 'temp';
action = @temp;
    function temp
    end

for i=1:numArgIn-1 % set paremeters from inputs
    curArg = varargin{i};
    
    if i==1
        if ishandle(varargin{1})
            h_parent = varargin{1};
            dataobj = h_parent;
        else
            h_parent = gcf;
        end
    end
    
    if ~ischar(curArg) % if not string, skip
        continue;
    end
    
    switch curArg
        case 'name' % the name of this slider
            name = varargin{i+1};
            i=i+1;
        case 'position' % position in [left, bottom, width, height]
            position = varargin{i+1};
            i=i+1;
        case 'dataobj' % the handle for the obj that contains data
            dataobj = varargin{i+1};
            i=i+1;
        case 'dataname' % the name of the varible being adjusted in dataobj
            dataname = varargin{i+1};
            if isappdata(dataobj,dataname);
                value = getappdata(dataobj,dataname);
            else
                setappdata(dataobj,dataname,value);
            end
            i=i+1;
        case 'scale' % the boundary of adjustable range [min, max]
            scale = varargin{i+1};
            i=i+1;
        case 'value' % initial value of the varible
            value = varargin{i+1};
            i=i+1;
        case 'rounded' % only alow rounded number
            rounded = varargin{i+1};
            i=i+1;
        case 'action'
            action = varargin{i+1};
            i=i+1;
    end
end

positionText = ...
    [ 1,  0,  0,  0
      0,  1,  0,0.5
      0,  0,0.2,  0
      0,  0,  0,0.5] * position(:);

positionEdit = ...
    [ 1,  0,0.3,  0
      0,  1,  0,0.5
      0,  0,0.4,  0
      0,  0,  0,0.5] * position(:);

positionSlider = ...
    [ 1,  0,  0,  0
      0,  1,  0,  0
      0,  0,  1,  0
      0,  0,  0,0.5] * position(:);


h_text = uicontrol(h_parent,'Style','text',...
    'String',name,...
    'Units','normalized', ...
    'Position',positionText, ...
    'BackgroundColor', get(h_parent,'Color'));

h_edit = uicontrol(h_parent,'Style', 'edit',...
    'String', num2str(value', '% .3f'), ...
    'Units','normalized', ...
    'Position', positionEdit, ...
    'BackgroundColor', 'w',...
    'Callback', {@editX_Callback});

h_slider = uicontrol(h_parent,'Style', 'slider',...
    'Min',scale(1),'Max',scale(2),'Value',value,...
    'Units','normalized', ...
    'Position', positionSlider,...
    'Callback', {@slideX_Callback});

h_myslider.h_text = h_text;
h_myslider.h_edit = h_edit;
h_myslider.h_slider = h_slider;

    function editX_Callback(~,~)
        ptX = str2double(get(h_edit,'String'));
        setdata(ptX);
    end

    function slideX_Callback(~, ~)
        if isnumeric(get(h_slider,'Value')) % if input is a number
            ptX = get(h_slider,'Value');
            setdata(ptX);
        end
    end

    function setdata(ptX)
        if ptX < scale(1)
            ptX = scale(1);
        elseif ptX > scale(2)
            ptX = scale(2);
        end
        
        if rounded
            ptX = round(ptX);
        end
        set(h_slider,'Value', ptX);
        set(h_edit,'String', num2str(ptX, '% .3f'));
        setappdata(dataobj,dataname,ptX);
        
        action();
    end

end