clear
clc
close all
kenlRatio = .01; % from the image, in terms of brightness, we take the fisrt 0.01 images 
minAtomsLight = 240; % the min atmosphere light 
hazydir = '../data/dense/'
savedir = './results/results_dense/'
imgset=dir(hazydir);
imgset=imgset(3:end);
nimg=size(imgset,1);
tic
for k=1:nimg
    img_name = imgset(k).name;  
    hazy_name=strcat(hazydir,img_name);
    img=imread(hazy_name);
    sz=size(img); % sz=[360 480 3]
    w=sz(2);  % w=480 the width of the image 
    h=sz(1);  % h=360 the height of the image 
    dc = zeros(h,w);
    for y=1:h
        for x=1:w
            dc(y,x) = min(img(y,x,:)); % this is the dark channel image 
        end
    end
    krnlsz = floor(max([3, w*kenlRatio, h*kenlRatio])); %to the closest integer
    dc2 = minfilt2(dc, [krnlsz,krnlsz]); %the min filter radius is 4 cm 
    dc2(h,w)=0;
    t = 255 - dc2;% dc2 is the image with fogs
    t_d=double(t)/255;
    sum(sum(t_d))/(h*w);
    A = min([minAtomsLight, max(max(dc2))]);
    J = zeros(h,w,3);
    img_d = double(img);
    r = krnlsz*4;
    eps = 10^-6;
    % filtered = guidedfilter_color(double(img)/255, t_d, r, eps);
    filtered = guidedfilter(double(rgb2gray(img))/255, t_d, r, eps);
    t_d = filtered;
    J(:,:,1) = (img_d(:,:,1) - (1-t_d)*A)./t_d;
    J(:,:,2) = (img_d(:,:,2) - (1-t_d)*A)./t_d;
    J(:,:,3) = (img_d(:,:,3) - (1-t_d)*A)./t_d;
    %----------------------------------
    %imwrite(uint8(J), ['./test_real/', img_name])
    dehaze = J/255;
    image_name_len = size(img_name,2);
    savename = [savedir,img_name(1:image_name_len-4),'_dcp',img_name(image_name_len-3:image_name_len)];
    imwrite(dehaze,savename);
end
toc