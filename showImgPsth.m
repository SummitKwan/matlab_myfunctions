function showImgPsth(video,psth)

frame_show =5;
[num_m,num_n,num_t] = size(video);

if num_t>100
    % pick several example frames to reduce the computational load
    eg_frames = randperm(num_t,100);
    eg_video = video(:,:,eg_frames);
    c_min = min(eg_video(:));
    c_max = max(eg_video(:));
else
    c_min = min(video(:));
    c_max = max(video(:));
end
c_range = [c_min,c_max];

figure;
colormap(gray);
h_img = axes('Position', [0.05,0.05,0.65,0.9]);
h_psth = axes('Position', [0.75,0.20,0.2,0.6]);

for t=frame_show+1 : num_t-frame_show
    
    set(gcf, 'CurrentAxes', h_img);
    imagesc(video(:,:,t));
    axis image;
    axis off;
    set(h_img,'cLim',c_range);
    title(num2str(t));
    
    set(gcf, 'CurrentAxes', h_psth);
    bar(h_psth, -frame_show:frame_show, psth(t-frame_show:t+frame_show));
    set(h_psth, 'xLim', [-frame_show,frame_show], 'yLim',[0,5], ...
        'xTick',0, 'xTickLabel', num2str(t));
    box off;
    title('psth');
    
    shg;
    pause(0.5);
end


end