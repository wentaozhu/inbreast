clear all; close all; clc;
impath = '.\AllDICOMs\';
roipath = '.\AllXML\';
detectbox = '.\detectannotmass.txt';
fid = fopen(detectbox, 'w');
files = dir([impath, '*.dcm']);
for i = 1 : length(files)
    id = files(i).name(1:length('20586908'));
    %if exist([impath, id, 'mask.jpeg'], 'file') == 2
    %    continue;
    %end
    im = dicomread([impath, files(i).name]);
    im = (double(im) + 0.0) ./ 4095.0 .* 255.0;
    im = uint8(im);
    if exist([roipath, id, '.xml'], 'file') ~= 2
        imwrite(im, [impath, id, 'mass.jpeg']);
        continue;
    end
    [mask, maxpoint, minpoint,excep] = readxml([roipath, id, '.xml'], size(im,1), size(im,2));
    if excep == 1
        display([roipath, id, '.xml']);
    end
    maxpoint = int32(maxpoint);
    minpoint = int32(minpoint);
    fprintf(fid, '%s ', [id, '.jpeg']);
    boundbox = zeros(size(im,1), size(im,2));
    for j = 1 : size(minpoint,1)
        fprintf(fid, '%d %d %d %d ', [minpoint(j,1),minpoint(j,2),maxpoint(j,1),maxpoint(j,2)]);
        boundbox(minpoint(j,1):maxpoint(j,1), minpoint(j,2)) = 255;
        boundbox(minpoint(j,1):maxpoint(j,1), maxpoint(j,2)) = 255;
        boundbox(minpoint(j,1), minpoint(j,2):maxpoint(j,2)) = 255;
        boundbox(maxpoint(j,1), minpoint(j,2):maxpoint(j,2)) = 255;
    end
    fprintf(fid, '\n');
    %fprintf(fid, '%f %f %f %f\n', [min(minpoint(:,1)),min(minpoint(:,2)),max(maxpoint(:,1)),max(maxpoint(:,2))]);
    %boundbox(min(minpoint(:,1)):max(maxpoint(:,1)), min(minpoint(:,2))) = 255;
    %boundbox(min(minpoint(:,1)):max(maxpoint(:,1)), max(maxpoint(:,2))) = 255;
    %boundbox(min(minpoint(:,1)), min(minpoint(:,2)):max(maxpoint(:,2))) = 255;
    %boundbox(max(maxpoint(:,1)), min(minpoint(:,2)):max(maxpoint(:,2))) = 255;
    mask(boundbox == 255) = 255;
    mask = imdilate(mask, strel('disk',10));
    imwrite(mask, [roipath, id, 'mass.jpeg']);
    imwrite(im, [impath, id, '.jpeg']);
    im(mask == 255) = 0;
    imwrite(im, [impath, id, 'maskmass.jpeg']);
end