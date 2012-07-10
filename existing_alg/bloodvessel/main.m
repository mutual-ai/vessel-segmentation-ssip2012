%function J = bv(I)
% Thitiporn Chanwimaluang
% tchanwim@gmail.com
% Department of Electrical and Computer Engineering
% Oklahoma State University

% This is the main function to perform blood vessel extraction

folder = 'Z:\pics\gold\glaucoma\glaucoma\'
files = dir([folder,'*.jpg']);
numFiles=length(files);
numFiles
for cf=1:numFiles
    cf
    outfilename = ['Z:\temp\results\',num2str(cf),'.tif']
    I = imread(fullfile(folder,files(cf).name));    
    IG = rgb2gray(I);
    [M,N] = size(IG);
    G(:,:,2) = I(:,:,2);
    G(:,:,1) = 0;
    G(:,:,3) = 0;
    Y = rgb2gray(G);

    sa = 2.0;
    rt = mim(Y,sa);

    [tt1,e1,cmtx] = myThreshold(rt);

    ms = 45;    
    mk = msk(IG,ms);

    rt2 = 255*ones(M,N);
    for i=1:M
        for j=1:N
            if rt(i,j)>=tt1 & mk(i,j)==255
                rt2(i,j)=0;
            end
        end
    end
    J = im2bw(rt2); 

    J= ~J;
    [Label,Num] = bwlabel(J);
    Lmtx = zeros(Num+1,1);
    for i=1:M
        for j=1:N
            Lmtx(double(Label(i,j))+1) = Lmtx(double(Label(i,j))+1) + 1;
        end
    end
    sLmtx = sort(Lmtx);
    cp = 950;
    for i=1:M
        for j=1:N
            if (Lmtx(double(Label(i,j)+1)) > cp) & (Lmtx(double(Label(i,j)+1)) ~= sLmtx(Num+1,1))
                J(i,j) = 0;
            else
                J(i,j) = 1;
            end
        end
    end
    for i=1:M
        for j=1:N
            if mk(i,j)==0
                J(i,j)=1;
            end
        end
    end
    %figure; imshow(J)
    imwrite(J, outfilename,'TIFF')    
end

