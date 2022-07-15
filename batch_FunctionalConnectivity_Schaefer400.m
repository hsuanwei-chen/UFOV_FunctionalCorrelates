clear; clc 

%Specify all necessary directories
%Select either DTS or UFOV
procdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates';
tooldir = '\\kki-gspnas1\DCN_data$\Stacy\CI_fmri\scripts\CNIR-fmri_preproc_toolbox-master';

%% Select atlas of interest
%Schaefer2018_400Parcels_7Networks
roi_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\Scripts\UFOV_FunctionalCorrelates\Schaefer2018_LocalGlobal\Parcellations\MNI';
roi_filenm_mask = 'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm';
tc_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates\Timecourse_Schaefer2018_400Parcels';
conn_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates\ConnectivityMatrices_Schaefer2018_400Parcels';

%Make relevant directories
if ~exist(tc_dir, 'dir')
    mkdir(tc_dir)
end
if ~exist(conn_dir, 'dir')
    mkdir(conn_dir)
    mkdir(fullfile(conn_dir, 'PearsonR'))
    mkdir(fullfile(conn_dir, 'FisherZ'))
end

%Add other directories with functions we will call on
addpath(tooldir)
addpath('\\kki-gspnas1\DCN_data$\Stacy\CI_fmri\scripts\spm12\spm12')

%Read in all the subject session data
slist = readtable(fullfile(procdir, 'ScansToPostProcess.csv'));

%Figure out how many subjects we will be running
istart = 1;
iend = length(slist.subject_id);

%% Loop through each subejct session
for isub = istart:iend
    ID = slist.subject_id{isub};
    sess_date = slist.sess_date{isub};
    task_dir = slist.task_dir{isub};
    
    fprintf('%i. Generating connectivity matrix for subject session: %s %s... \n', isub, ID, sess_date);
    %rename_task: e.g., task-rest_bold or task-ftap_bold; processing script will copy
    %       and rename func_files to procdir/ID using the following convention -
    %       sub-ID/sess-DateOfSession/func/task_dir/run-??/sub-ID_sess-DateOfSession_rename_task_run-??.nii,
    %       where run number is determined by the order of func_files
    if task_dir == 'ftap'
        rename_task = 'task-ftap_bold';        
        fprintf('Scan type: %s \n', task_dir); 
    elseif task_dir == 'rest'
        rename_task = 'task-rest_bold';
        fprintf('Scan type: %s \n', task_dir); 
    end
    
    %Specify directory with final post-processed file
    data_dir = fullfile(procdir, ID, sess_date, 'func', task_dir, 'run-01');
   
    %Specify final post-processed file name
    data_filenm_mask = strcat('fsnwc50fwepia', ID, '_', sess_date, '_', rename_task, '_run-01');
    
    %Extract mean timecourse
    disp("Extracting mean timecourse...")
    roi_tc_seeds(data_dir, roi_dir, data_filenm_mask, roi_filenm_mask);
    
    %Locate timecourse files
    tc_fname = strcat(data_filenm_mask, "_", roi_filenm_mask(1:23), "_mn_tc");
    tc_csv = fullfile(data_dir, strcat(tc_fname, ".csv"));
    tc_mat = fullfile(data_dir, strcat(tc_fname, ".mat"));
    
    %Computing correlations
    disp("Computing correlations...")
    for rois = 1:length(roi_filenm_mask);
        load(tc_mat);   %variable name is called mn_roi
        tcs = mn_roi.tc';
    end 
    
    pearsonR = corrcoef(tcs);
    fisherZ = fisher_r2z(pearsonR);
    
    %Save individual timecourse and connectivity matrices to group folder
    disp("Saving results...");
    copyfile(tc_csv, tc_dir);
    
    pearsonR_fname = strcat('fsnwc50fwepia', ID, '_', sess_date, '_', rename_task, '_run-01_pearsonR_conn.csv');
    fisherZ_fname = strcat('fsnwc50fwepia', ID, '_', sess_date, '_', rename_task, '_run-01_fisherZ_conn.csv');
    csvwrite(fullfile(conn_dir, 'PearsonR', pearsonR_fname), pearsonR);
    csvwrite(fullfile(conn_dir, 'FisherZ', fisherZ_fname), fisherZ);

    fprintf("Complete! \n");
    
    %clearvars -except procdir tooldir roi_dir roi_filenm_mask tc_dir conn_dir slist istart iend
end

%% Function for extracting timecourse
function mn_roi = roi_tc_seeds(data_dir,roi_dir, ...
    data_filenm_mask, roi_filenm_mask, brain_mask_file)
%Function to create mean ROI timecourse given an ROI (mask/seed) and the
%dataset
%Usage
%   mn_roi_tc = roi_mn_tc(data_dir,roi_dir,data_filenm_mask, ...
%       roi_filename_mask,brain_mask_file)
%   data_dir - directory containing the preprocessed data files (3D nifti)
%   roi_dir  - directory containing the ROI masks
%   data_filenm_mask - string containing the common substring for the
%       preprocessed files (typically 'fswa' or 'swa')
%   roi_filenm_mask - string containing the common substring for the ROI
%       files (typically {'RSN','ACC'})
%   brain_mask_file - string with brain mask filename

% by Suresh E Joel - modified July, 2009; modified Sep 16,2009

if(nargin<4),
    error('Not enough arguements');
end;

%% Get orientation of data file (to match all masks to the same orientation)
disp("Getting data file dimensions...")
ffiles=fullfile(data_dir,[data_filenm_mask,'.nii']);
V = spm_vol(ffiles);
Y = spm_read_vols(V);
Y = reshape(Y, [numel(Y(:, :, :, 1)), numel(Y(1, 1, 1, :))]);
clear V;

%% Read the ROI mask files
hw=waitbar(0,'Reading Mask Files');
files=fullfile(roi_dir,[roi_filenm_mask,'.nii']);
[path mn_roi.name ext] = fileparts(files);

V=spm_vol(files);
sM=spm_read_vols(V);
seeds = unique(nonzeros(sM));
waitbar(1,hw);

%% Compute mean of the seed ROI region
waitbar(0,hw,'Reading & computing ROI mean timecourse');
clear files V P;

seedMat = false(size(Y, 1), length(seeds));
for iroi = 1:length(seeds)
    %find all indices that correspond to a unique value in the mask for each row
    seedMat(:, iroi) = sM(:) == seeds(iroi); 
end

mn_roi.tc = zeros(length(seeds), size(Y, 2));
for iroi = 1:length(seeds)
    %find all the nonzero elements in seedMat
    indices = find(seedMat(:, iroi));
    %computer mean for the nonzero elements per column/timepoint
    mn_roi.tc(iroi,:)= mean(Y(indices, :));
    waitbar(iroi/length(seeds),hw);
end;

disp('Saving Timecourses...');
%% Save the timecourses
save([ffiles(1:end-4), '_', mn_roi.name(1:23),'_mn_tc.mat'],'mn_roi');
csvwrite([ffiles(1:end-4), '_', mn_roi.name(1:23),'_mn_tc.csv'], mn_roi.tc);
waitbar(0,hw,'Saving mean timecourses');
close(hw);
end

function z=fisher_r2z(r)
%prevst=warning('off','MATLAB:divideByZero');
z=real(1/2 .* log((1+r)./(1-r)));
%warning(prevst);
end
