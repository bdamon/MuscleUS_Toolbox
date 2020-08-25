function fiber_visualizer_us(image_doub, fiber_all, roi_struc)

%%
figure('units', 'normalized', 'position', [0.1 .1 .8 .75])
imagesc(image_doub), colormap gray
axis image
hold on

if nargin>1
    if exist('fiber_all', 'var')
        for k = 1:length(fiber_all(:,1,1))
            loop_c = nonzeros(squeeze(fiber_all(k,:,2)));
            loop_r = nonzeros(squeeze(fiber_all(k,:,1)));
            plot(loop_c, loop_r, 'y')
        end
    end
    
    if exist('roi_struc', 'var')
        for k = 1:length(fiber_all(:,1,1))
            plot(roi_struc.fitted_c_pixels, roi_struc.fitted_r_pixels, 'c')
        end
    end

end


%% end function
return;