% batch evaluation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folders = {
     './../img/gold/healthy/healthy/'
%     './../img/gold/glaucoma/glaucoma/'
%    './../img/gold/retinopathy/diabetic_retinopathy/'
};

FRANGI_ON = 0; %hessian
RVS_ON    = 1; %our implementation
BV_ON     = 0; %bloodvessel folder
RESULTS_LOCATION = './../results/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for folderNum = 1:length(folders)
    folder = folders{folderNum};
    %fov_folder = strcat(folder(1:end-1),'_fovmask/');
    gt_folder = strcat(folder(1:end-1),'_manualsegm/');
    files = dir([folder,'*.jpg']);
    numFiles=length(files);
    out_dir = strcat(RESULTS_LOCATION, strrep(folder, './../img/', ''));
    out_dir_hessian = strcat(out_dir,'frangi/');
    out_dir_rvs = strcat(out_dir,'rvs/');
    out_dir_bv = strcat(out_dir,'bv/');
    
    if (FRANGI_ON) && (~exist(out_dir_hessian,'dir'))
        throw(MException('FolderNotExists', 'The folder that should contain the result images does not exist.'));
    end
    if (RVS_ON) && (~exist(out_dir_rvs,'dir'))
        throw(MException('FolderNotExists', 'The folder that should contain the result images does not exist.'));
    end
    if (BV_ON) && (~exist(out_dir_bv,'dir'))
        throw(MException('FolderNotExists', 'The folder that should contain the result images does not exist.'));
    end
    
    writeResultIndex = 0;
    while writeResultIndex <= 3
        writeResultIndex = writeResultIndex + 1;
        clear res_out_dir
        csv_data = {'algorithm','filename','sens','spec','accu','con','area','leng','prec'};
        if  (writeResultIndex==1) && (FRANGI_ON)
            res_out_dir = out_dir_hessian;
            which_alg = 'frangi';
        end
        if (writeResultIndex==2 ) && (RVS_ON)
            res_out_dir = out_dir_rvs;
            which_alg = 'rvs';
        end
        if (writeResultIndex==3) && (BV_ON)
            res_out_dir = out_dir_bv;
            which_alg = 'bv';
        end
        if ~ (exist('res_out_dir','var'))
            continue;
        end
        
        for fileNum = 1:numFiles
            res_img_path = strcat(res_out_dir,files(fileNum).name);
            res_img = imread(res_img_path);
            gt_path = strcat(gt_folder,files(fileNum).name(1:end-3),'tif');
            gt_img = imread(gt_path);
            [sens spec accu con area leng prec] = evaluation(gt_img,res_img);
            csv_data(fileNum+1,:) = {which_alg,files(fileNum).name,sens,spec,accu,con,area,leng,prec};
        end
        
        fid = fopen(strcat(res_out_dir,strcat('batch_results','.csv')),'wt');
        fprintf(fid, '%s,',csv_data{1,:});
        fprintf(fid, '\n');
        for i=2:length(files)+1
            fprintf(fid, '%s,',csv_data{i,1});
            fprintf(fid, '%s,',csv_data{i,2});
            fprintf(fid, '%f,',csv_data{i,3});
            fprintf(fid, '%f,',csv_data{i,4});
            fprintf(fid, '%f,',csv_data{i,5});
            fprintf(fid, '%f,',csv_data{i,6});
            fprintf(fid, '%f,',csv_data{i,7});
            fprintf(fid, '%f,',csv_data{i,8});
            fprintf(fid, '%f,\n',csv_data{i,9});
        end
        fprintf(fid, '\n');
        fclose(fid);
        
    end
    
    
end

