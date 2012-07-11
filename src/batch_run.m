% add all needed function paths
try
    functionname='batch_run.m';
    functiondir=which(functionname);
    functiondir=functiondir(1:end-length(functionname));
    addpath([functiondir '/../existing_alg/hessian/'],[functiondir '/../existing_alg/bloodvessel/']);
catch me
    disp(me.message);
end
warning('off', 'MATLAB:conv2:uint8Obsolete');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folders = {
    './../img/gold/healthy/healthy/'
 %   './../img/gold/glaucoma/glaucoma/';
 %   './../img/gold/retinopathy/retinopathy/'
};

FRANGI_ON = 0; %hessian
RVS_ON    = 1; %our implementation
BV_ON     = 0; %bloodvessel folder
RESULTS_LOCATION = './../results/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for folderNum = 1:length(folders)
    folder = folders{folderNum};
    fov_folder = strcat(folder(1:end-1),'_fovmask/');
    gt_folder = strcat(folder(1:end-1),'_manualsegm/');
    files = dir([folder,'*.jpg']);
    numFiles=length(files);
    out_dir = strcat(RESULTS_LOCATION, strrep(folder, './../img/', ''));
    out_dir_hessian = strcat(out_dir,'frangi/');
    out_dir_rvs = strcat(out_dir,'rvs/');
    out_dir_bv = strcat(out_dir,'bv/');

    if FRANGI_ON
        cvs_frangi = cell(numFiles+1,8);
        cvs_frangi(1,:) = {'algorithm','filename','sens','spec','accu','con','area','leng'};
        if ~exist(out_dir_hessian,'dir')
            mkdir('.',out_dir_hessian);
        end
    end
    if RVS_ON
        cvs_rvs = cell(numFiles+1,8);
        cvs_rvs(1,:) = {'algorithm','filename','sens','spec','accu','con','area','leng'};
        if ~exist(out_dir_rvs,'dir')
            mkdir('.',out_dir_rvs);
        end
    end
    if BV_ON
        cvs_bv = cell(numFiles+1,8);
        cvs_bv(1,:) = {'algorithm','filename','sens','spec','accu','con','area','leng'};
        if ~exist(out_dir_bv,'dir')
            mkdir('.',out_dir_bv);
        end
    end
    
    for fileNum = 1:length(files)
        in_img_path = strcat(folder,files(fileNum).name);
        in_img_base  = imread(in_img_path);
        in_img_double = double(in_img_base);
        in_img_gray_int = rgb2gray(in_img_base);
        in_img = double(in_img_gray_int);
        fov_path = strcat(fov_folder,files(fileNum).name(1:end-4),'_mask.tif');
        fov_img = imread(fov_path);
        gt_path = strcat(gt_folder,files(fileNum).name(1:end-3),'tif');
        gt_img = imread(gt_path);
        
        if FRANGI_ON
            out_img_hessian = FrangiFilter2D(in_img,struct('verbose', false));
            fov_img_dilated = imerode(fov_img, strel('disk', 1));
            out_img_hessian = (double(fov_img_dilated(:, :, 1)) .* out_img_hessian);
            out_img_hessian = im2bw(out_img_hessian, 0.7);
            imwrite(out_img_hessian,strcat(out_dir_hessian,files(fileNum).name));
            [sens spec accu con area leng] = evaluation(gt_img,out_img_hessian);
            cvs_frangi(fileNum+1,:) = {'frangi',files(fileNum).name,sens,spec,accu,con,area,leng};
        end
        if RVS_ON
            out_img_rvs = RVS(in_img_path);
            imwrite(out_img_rvs,strcat(out_dir_rvs,files(fileNum).name));
            [sens spec accu con area leng] = evaluation(gt_img,out_img_rvs);
            cvs_rvs(fileNum+1,:) = {'rvs',files(fileNum).name,sens,spec,accu,con,area,leng};
        end
        if BV_ON
            out_img_bv = imcomplement(bv(in_img_base));
            imwrite(out_img_bv,strcat(out_dir_bv,files(fileNum).name));
            [sens spec accu con area leng] = evaluation(gt_img,out_img_bv);
            cvs_bv(fileNum+1,:) = {'bv',files(fileNum).name,sens,spec,accu,con,area,leng};
        end
    end
    
    writeResultIndex = 1;
    while writeResultIndex <= 3
        if  (writeResultIndex==1) && (FRANGI_ON)
            res_out_dir = out_dir_hessian;
            cvs_data = cvs_frangi;
        end
        if (writeResultIndex==2 ) && RVS_ON
            res_out_dir = out_dir_rvs;
            cvs_data = cvs_rvs;
        end
        if (writeResultIndex==3) && BV_ON
            res_out_dir = out_dir_bv;
            cvs_data = cvs_bv;
        end
        
        fid = fopen(strcat(res_out_dir,strcat('batch_results','.csv')),'wt');
        fprintf(fid, '%s;',cvs_data{1,:});
        fprintf(fid, '\n');
        for i=2:length(files)+1
            fprintf(fid, '%s,',cvs_data{i,1});
            fprintf(fid, '%s,',cvs_data{i,2});
            fprintf(fid, '%f,',cvs_data{i,3});
            fprintf(fid, '%f,',cvs_data{i,4});
            fprintf(fid, '%f,',cvs_data{i,5});
            fprintf(fid, '%f,',cvs_data{i,6});
            fprintf(fid, '%f,',cvs_data{i,7});
            fprintf(fid, '%f,\n',cvs_data{i,8});
        end
        fprintf(fid, '\n');
        fclose(fid);
        
        writeResultIndex = writeResultIndex + 1;
     end

    warning('on', 'MATLAB:conv2:uint8Obsolete');
end


