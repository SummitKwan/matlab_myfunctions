function myvideoshow(video, varargin)
% video should be a num array, [m*n*t], in double

[num_m,num_n,num_frame] = size(video);

% initialize psth data
psth = zeros(1,num_frame);
% determin the default frequency for showing images
freq = 25;
% determine the range for color map
if num_frame>100
    % pick several example frames to reduce the computational load
    eg_frames = randperm(num_frame,100);
    eg_video = video(:,:,eg_frames);
    c_min = min(eg_video(:));
    c_max = max(eg_video(:));
else
    c_min = min(video(:));
    c_max = max(video(:));
end
c_range = [c_min,c_max];


for i=1:length(varargin)
    if ischar(varargin{i})
        if strcmp(varargin{i}, 'psth')
            psth = varargin{i+1};
        elseif strcmp(varargin{i},'freq')
            freq = varargin{i+1};
        elseif strcmp(varargin{i},'c_range')
            c_range = varargin{i+1};
        end
    end
end



h_fig = figure;
set(h_fig, 'CloseRequestFcn', {@stop_Callback});
colormap(gray(256));

% button for stop playing
h_stop = uicontrol('Style','pushbutton', ...
    'String', 'STOP', ...
    'Units','normalized', ...
    'Position', [0.90,0.9,0.1,0.08], ...
    'Userdata', 0, ...
    'Callback', {@stop_Callback});

% button for pause/play
h_pause = uicontrol('Style','pushbutton', ...
    'String', 'PAUSE', ...
    'Units','normalized', ...
    'Position', [0.80,0.9,0.1,0.08], ...
    'Userdata', 0, ...
    'Callback', {@pause_Callback});

% button for play the previous frame
h_frameback = uicontrol('Style','pushbutton', ...
    'String', '<', ...
    'Units','normalized', ...
    'Position', [0.5,0.93,0.05,0.05], ...
    'Userdata', 0, ...
    'Callback', {@frameback_Callback});

% button for play the next frame
h_frameforward = uicontrol('Style','pushbutton', ...
    'String', '>', ...
    'Units','normalized', ...
    'Position', [0.75,0.93,0.05,0.05], ...
    'Userdata', 0, ...
    'Callback', {@frameforward_Callback});

% the edible text box for frame number
h_frame = uicontrol('Style', 'edit',...
    'String', '1', ...
    'Units','normalized', ...
    'Position', [0.55,0.93,0.20,0.05], ...
    'BackgroundColor', 'w',...
    'Callback', {@frame_Callback});

% slider bar for frame number
h_frame_slider = uicontrol('Style', 'slider',...
    'Min',1,'Max',num_frame,'Value',1,...
    'Units','normalized', ...
    'Position', [0.5, 0.9, 0.30, 0.03],...
    'Callback', {@slideframe_Callback});

% axes for showing movie
h_movie_axes = axes('Units','normalized', 'Position', [0.03,0.03,0.96,0.85]);
h_movie_obj = imagesc(video(:,:,round(get(h_frame_slider,'Value'))));    
axis image;
axis off;
set(gca,'cLim',c_range);
colorbar;

% axes for showing video
h_psth_axes = axes('Units','normalized', 'Position', [0.10,0.9,0.40,0.1]);
hold on;
h_psth_obj = plot(psth,'b-');
h_psth_draw_obj = plot(psth(1),'ro','LineWidth',2);
axis off;
box off;

% the value for psth
h_psth_value = uicontrol('Style', 'text',...
    'String', num2str(psth(1)), ...
    'Units','normalized', ...
    'Position', [0.00,0.93,0.10,0.03] );

% Cycle as routine
while get(h_frame_slider,'Value')<=num_frame
    % if press STOP, break cycle
    if get(h_stop, 'UserData') == 1
        break;
    end
    
    % get the frame index to be drawn
    if get(h_frame_slider,'Value') <1
        set(h_frame_slider,'Value',1);
    elseif get(h_frame_slider,'Value') >num_frame
        set(h_frame_slider,'Value',num_frame);
    end
    frame_draw = round(get(h_frame_slider,'Value'));
    
    % set text box for frame number
    set(h_frame, 'String', num2str(frame_draw, '% .0f'));
    
    % refresh image and psth data
    set(h_movie_obj, 'CData', video(:,:,frame_draw));
    set(h_psth_draw_obj, 'XData', frame_draw,...
        'YData', psth(frame_draw));
    set(h_psth_value,'String',num2str(psth(frame_draw)));
    refreshdata;
    pause(1/freq);
    
    if get(h_pause, 'UserData') == 0 ...
            && get(h_frame_slider, 'Value')<=num_frame-1;
        set(h_frame_slider, 'Value', round(get(h_frame_slider,'Value'))+1);
    elseif get(h_pause, 'UserData') == 1
        pause(0.5);
    end
end


%% callback functions
    function stop_Callback(~, ~)
        if get(h_stop, 'UserData')==0
            set(h_stop, 'UserData', 1);
            set(h_stop, 'String', 'CLOSE');
            disp('Video show stopped since you pressed [STOP] button');
        elseif get(h_stop, 'UserData')==1
            set(h_stop, 'UserData', 2);
            closereq;
            disp('Video show stopped since you pressed [STOP] button');
        end
    end

    function pause_Callback(~, ~)
        if get(h_pause, 'UserData') == 0;
            set(h_pause, 'UserData', 1);
            set(h_pause, 'String', 'PLAY');
            disp('Video show paused since you pressed [PAUSE] button');
        elseif get(h_pause, 'UserData') == 1;
            set(h_pause, 'UserData', 0);
            set(h_pause, 'String', 'PAUSE');
            disp('Video show continued since you pressed [PLAY] button');
        end
    end
    
    function frameback_Callback(~, ~)
        frame_now = round(get(h_frame_slider,'Value'))-1;
        if frame_now>=1 && frame_now<=num_frame
            set(h_frame_slider,'Value', frame_now);
            set(h_frame,'String',num2str(frame_now, '% .0f'));
        end
    end

    function frameforward_Callback(~, ~)
        frame_now = round(get(h_frame_slider,'Value'))+1;
        if frame_now>=1 && frame_now<=num_frame
            set(h_frame_slider,'Value', frame_now);
            set(h_frame,'String',num2str(frame_now, '% .0f'));
        end
    end

    function slideframe_Callback(~, ~)
        frame_now = round(get(h_frame_slider,'Value'));
        set(h_frame_slider,'Value', frame_now);
        set(h_frame,'String',num2str(frame_now, '% .0f'));
    end

    function frame_Callback(~,~)
        frame_now = round(str2double(get(h_frame,'String')));
        set(h_frame_slider,'Value', frame_now);
    end

end