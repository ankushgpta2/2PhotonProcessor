%% generate corresponding figures to see if registration worked and save them 

% Test for whether or not the registration worked for the slices (plotting
% x-y for the parameters contained within the fall.mat file 

mkdir(fullfile(expdir, 'registration_figures'));
reg_figures_path = fullfile(expdir, 'registration_figures');
addpath(reg_figures_path);

Frames = length(Xoff);

figure(1);
plot(1:Frames,Xoff, 'b.'); 
hold on;
plot(1:Frames,Yoff, 'r.');
grid;
axis square;
legend('XOffset Accross Frames');
Name1 = fullfile([experiment, ' / ', genotype, ' -- XOffset vs Y Offset']);
title(Name1);
xlabel('Frames');
ylabel('X-Y Offset Value'); 
saveas(gcf, fullfile(reg_figures_path, 'XOffvsYOff'), 'epsc');
hold off;

figure(2);
DeltaX = diff(Xoff);
DeltaY = diff(Yoff); 
plot(1:Frames-1,DeltaX, 'b.');
hold on;
plot(1:Frames-1,DeltaY, 'r.');
grid;
axis square;
legend('DeltaXOffset Accross Frames');
Name2 = fullfile([experiment, ' / ', genotype,' -- Delta X vs Delta Y']);
title(Name2);
xlabel('Frames');
ylabel('DeltaX-Y Offset Value'); 
saveas(gcf, fullfile(reg_figures_path, 'DeltaXvsDeltaY'), 'epsc');
hold off; 

figure(3);
plot(DeltaX(1:end-1),DeltaX(2:end), 'b.');
hold on;
plot(DeltaY(1:end-1),DeltaY(2:end), 'r.');
grid;
axis square;
legend('X');
Name3 = fullfile([experiment, ' / ', genotype, ' -- Change In Delta Offset']); 
title(Name3);
xlabel('DeltaOffset');
ylabel('DeltaOffset for X & Y for Next Time Point'); 
saveas(gcf, fullfile(reg_figures_path, 'ChangeInDeltaOffset'), 'epsc');
hold off; 

figure(4);
XSquared = Xoff.^2;
YSquared = Yoff.^2;
Combined = XSquared + YSquared;
Final = double(Combined);
SquareRoot = sqrt(Final);
plot(1:Frames,SquareRoot, 'r.');
axis square;
legend('X-Y Displacement');
Name4 = fullfile([experiment, ' / ', genotype, ' -- Overall Hypotenuse Displacement']); 
title(Name4);
xlabel('Frames');
ylabel('Hypotenuse of X and Y Displacement Vectors');
saveas(gcf, fullfile(reg_figures_path, 'OverallDisplacement'), 'epsc');
hold off; 
