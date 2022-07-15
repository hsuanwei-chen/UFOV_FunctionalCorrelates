clear; clc 

%Specify all necessary directories
procdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates';
tooldir = '\\kki-gspnas1\DCN_data$\Stacy\CI_fmri\scripts\CNIR-fmri_preproc_toolbox-master';

%% Select atlas of interest
%Yeo2011 7 Networks Atlas
roi_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\Scripts\UFOV_FunctionalCorrelates\Yeo_JNeurophysiol11_MNI152';
roi_filenm_mask = 'Yeo2011_7Networks_MNI152_FreeSurferConformed2mm_LiberalMask';
tc_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates\Timecourse_Yeo2011_7Networks';
conn_dir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates\ConnectivityMatrices_Yeo2011_7Networks';

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
addpath('\\kki-gspnas1\DCN_data$\Stacy\Scans\Scripts\seed-based-connectivity-master')

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
    tc_fname = strcat(data_filenm_mask, "_", roi_filenm_mask, "_mn_tc");
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
    
    clearvars -except procdir tooldir roi_dir roi_filenm_mask tc_dir conn_dir slist istart iend
end