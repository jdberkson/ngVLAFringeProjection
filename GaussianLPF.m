function [Data,OutMap] = GaussianLPF(Data,InMap, sigmax, sigmay, theta, usrinpt)
%% Description:
% This function applies a Gaussian Low-Pass Filter to an image given the standard
% deviation in x and y and the input image to be filtered. The function returns
% the filtered map as well as the filter function. It also displays the
% final filtered image as well as the filter and the unfiltered FFT for
% reference.

%Inputs:
%   Data: Data structure where Data.surfaceData is the sag map
%   InMap: Map of Data to be filtered
%   sigmax: standard deviation in x
%   sigmay: standard deviation in y
%   theta: rotation of Gaussian (in degrees)
%   usrinpt: 1 for manual input of Gaussian, 0 for using current
%   Data.sigmax and Data.sigmay values

%Outputs:
%   OutMap: out filtered map

%Grab surface data
%% 

A = InMap;
%Set all NaN pixels to zero, but save indexes to replace later
% nanidx = find(isnan(A));
% A(isnan(A)) = 0;
A = fft2(double(A)); % compute FFT of the grey image
A1=fftshift(A); % frequency shifting
[M, N]=size(A); % image size
X=0:N-1;
Y=0:M-1;
[X, Y]=meshgrid(X,Y);
Cx=0.5*N;   %Center x
Cy=0.5*M;   %Center y

%Gaussian filter function centered at (Cx,Cy) with standard deviations
%sigmax and sigmay

% Check for user input mode
if usrinpt == 1
    response = 'No';
    while strcmp(response,'No')
            f = figure;
            prompt = {'Enter \sigma_x size:','Enter \sigma_y value:'};
            dlgtitle = 'Input';
            dims = [1 35];
            definput = {'1','1'};
            %Creat dialogue bos for entering sigmax and sigmay
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            sigmax = str2num(answer{1});
            sigmay = str2num(answer{2});
            Data.sigmax = sigmax;
            Data.sigmay = sigmay;
            %LowPass Filter
            Lo=exp(-((X-Cx).^2./(2*sigmax).^2+(Y-Cy).^2./(2*sigmay).^2));

        %Clocking
        if theta ~= 0
           Lo = imrotate(Lo, theta, 'bicubic', 'crop');
        end

        % Filtered image=ifft(filter response*fft(original image))
        J=A1.*Lo;
        J1=ifftshift(J);
        OutMap=real(ifft2(J1));

%         OutMap(nanidx) = NaN;

        %Plotting
        subplot(2,2,1)
        imagesc(InMap)
        title("Unfiltered Image")
        subplot(2,2,2)
        imagesc(OutMap)
        title("Filtered Image")
        subplot(2,2,3)
        imagesc(5*abs(A1)/max(max(abs(A1))))
        title("Unfiltered image FFT")
        subplot(2,2,4)
        imagesc(Lo)
        title("Gaussian Filter")

        while ishandle(f)
            pause(1)
        end
        response = questdlg('Are you satisfied with the filter?','Prompt','Yes','No','Yes');
        if strcmp(response,'Yes')
            break;
        end
    end
else  %Script if user input mode is off
    Lo=exp(-((X-Cx).^2./(sigmax).^2+(Y-Cy).^2./(sigmay).^2)/2);

    %Clocking
    if theta ~= 0
       Lo = imrotate(Lo, theta, 'bicubic', 'crop');
    end
    % Filtered image=ifft(filter response*fft(original image))
    J=A1.*Lo;
    J1=ifftshift(J);
    OutMap=real(ifft2(J1));
end


end

