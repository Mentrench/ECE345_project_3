    figure; % Create a new figure window
    hold on; % Keep the plot active for adding elements
    title('BER vs SNR Proxy, log(1/sigma^2) plotted');
    xlabel('log_{10}(1 / \sigma^2) (Proxy for SNR)');
    ylabel('log_{10}(Bit Error Rate)');

    x_coords = log_inv_sigma2(valid_idx); % Initialize arrays to store points
    y_coords = log_BER(valid_idx);

    % Plot only the lines connecting the points, without showing the initial points
    grid on;
    xlim([3 7]); 
    ylim([-4 0]);

    while true
        [x, y, button] = ginput(1); % Get one point (x, y) and button code
        
        if button == 3 % Right-click to finish
            break; % Exit the loop
        else
            x_coords(end+1) = x; % Add new point
            y_coords(end+1) = y;
            
            % Plot lines connecting the points without markers
            plot(x_coords, y_coords, '-', 'LineWidth', 2); 
            drawnow; % Update the figure immediately
        end
    end

    hold off; % Release the plot
    disp('Points selected and connected.'); % Inform the user that points were added
