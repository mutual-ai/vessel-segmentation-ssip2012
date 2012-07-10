% add all needed function paths
try
    functionname='batch_run.m';
    functiondir=which(functionname);
    functiondir=functiondir(1:end-length(functionname));
    addpath([functiondir '/../existing_alg/hessian/'],[functiondir '/../existing_alg/bloodvessel/']);
catch me
    disp(me.message);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folders = {
    './../img/gold/healthy/healthy/';
    './../img/gold/glaucoma/glaucoma/';
    './../img/gold/retinopathy/retinopathy/'
};

FRANGI_ON = 1; %hessian
RVS_ON    = 0;
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
    if (FRANGI_ON) && (~exist(out_dir_hessian,'dir'))
        mkdir('.',out_dir_hessian);
    end
    if (RVS_ON) && (~exist(out_dir_rvs,'dir'))
        mkdir('.',out_dir_rvs);
    end
    
    for fileNum = 1:length(files)
        in_img_path = strcat(folder,files(fileNum).name);
        in_img_base  = imread(in_img_path);
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
            [sens spec accu con area leng] = evaluation(gt_img,out_img_hessian)
        end
        if RVS_ON
            out_img_rvs = RVS(in_img_path);
            imwrite(out_img_rvs,strcat(out_dir_rvs,files(fileNum).name));
        end
    end
end


