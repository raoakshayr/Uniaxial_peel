%detect markers and label them and obtain initial distances
%% Initialize, this code is for measurements of peel/uniaxial specimen dimensions
close all;
clearvars;
clc;
clear figs;
recordflag=0;
%% Read in image
specimen='BMEL-18-09-016-A ';
imagename='Vimba_0_';
filextbmp='.bmp';
im_i=input('Which image would you like to use for inital length measurement? \n','s');
fnamejpg=strcat(imagename,im_i,filextbmp);
A=imread(fnamejpg);
B=A;

%% number of markerspans
figure
imshow(B)
n_markers=input('How many markers are there for this measurement? \n');
close
%% Crop Region of Interest
disp('Crop region of interest \n');
[C,C_rect]=imcrop(B);
close
%% First we obtain the markers
% Choose threshold such that all markers are visible
flag=0;
D=imcomplement(C); 
while flag==0
    T=input('Please enter the thresholding value between 0 and 1 to locate markers \n');
    E=imbinarize(D,T);
    figure;
    imshowpair(D,E,'montage')
    done=input('Change threshold? y/n \n','s');
    close
    if done=='n';
        flag=1;
    end
end

%% Apply area filter
flag=0;
while flag==0
    ar=input('Would you like to use default area filter? y/n \n','s');
    if ar=='y'
        areamax=400;
        areamin=100;
    elseif ar=='n'
        areamin=input('Enter min area');
        areamax=input('Enter max area');
    end
    
    areafilterE=bwareafilt(E,[areamin areamax]);
    figure
    title('Area filter ')
    imshowpair(E,areafilterE,'montage');
    done=input('Change Area filter? y/n \n','s');
    close
    if done=='n';
        flag=1;
    end
end
%% Erode and dilate
flag=0;
while flag==0
    er=input('Would you like to erode and dilate the image? y/n \n','s');
    
    r_er=0;
    r_dil=0;
    if er=='y'
        r_er=input('Enter erosion radius y/n \n','s');
        r_dil=input('Enter dilation radius y/n \n','s');
        
        SE_er = strel('diamond',str2double(r_er));
        SE_dil = strel('diamond',str2double(r_dil));
        IM = imerode(areafilterE,SE_er);
        G = imdilate(IM,SE_dil);
        figure
        imshowpair(areafilterE,G,'montage');
        done=input('Change erosion and dilation? y/n \n','s');
        close
        if done=='n';
            flag=1;
        end
    else
        G=areafilterE;
        break;
    end
end
%% Compute convex polygon and centroid for each object
conveximage = regionprops(G,'ConvexImage');
centroids=regionprops(G,'Centroid');
eccentricity=regionprops(G,'Eccentricity');
cens = cat(1, centroids.Centroid);
eccs=cat(1,eccentricity.Eccentricity);
%% To label each markers index in the reference position
disp('Please provide the indices of the markers, starting from 1 at the top\n');
linc=1;
rinc=1;
for i=1:length(cens)
    figure
    imshow(G)
    hold on
    plot(cens(i,1),cens(i,2), 'b*')
    hold off
    arm=input('Is the marker in the left arm or the right arm? l/r ?','s');
    if (arm=='l')
        censl_i(linc,1)=input('What is the index of this marker?');
        censl_i(linc,2)=i;
        linc=linc+1;
    elseif (arm=='r')
        censr_i(rinc,1)=input('What is the index of this marker?');
        censr_i(rinc,2)=i;
        rinc=rinc+1;
    end
    close
end
[R,RI]=sort(censr_i(:,1));


[L,LI]=sort(censl_i(:,1));

%% To measure initial distances of the markers
for i =1:length(censl_i)-1
    delx=(cens(censl_i(LI(i),2),1)-cens(censl_i(LI(i+1),2),1))^2;
    dely=(cens(censl_i(LI(i),2),2)-cens(censl_i(LI(i+1),2),2))^2;
    indist_l(i)=(delx+dely)^.5;
end

for i =1:length(censr_i)-1
    delx=(cens(censr_i(RI(i),2),1)-cens(censr_i(RI(i+1),2),1))^2;
    dely=(cens(censr_i(RI(i),2),2)-cens(censr_i(RI(i+1),2),2))^2;
    indist_r(i)=(delx+dely)^.5;
end
figure
imshow(G)

disp('Press key to continue\n');
w = waitforbuttonpress;
close
%% Save to .mat
save('indist.mat','indist_l','indist_r')

