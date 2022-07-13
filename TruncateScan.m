%This is a script designed to truncate scan data and extract dynamics that
%are non-motion contaminated
clear; clc 
addpath('T:\Stacy\CI_fmri\scripts\spm12\spm12')

frawdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY';
%procdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\Adrian_DTS_RestingState';
procdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\Adrian_UFOV_RestingState';
dcm2nii_toolbox = '\\kki-gspnas1\DCN_data$\Stacy\CI_fmri\scripts\dcm2niix_02-Nov-2020_win';

slist = readtable(fullfile(procdir, 'ScansToTruncate.csv'));

istart = 1;
iend = length(slist.subject_id);

for isub = istart:iend
    subid = slist.subject_id{isub};
    scan_date = char(slist.scan_date(isub));
    scan_date = strcat(scan_date(1:2), '_', scan_date(4:5), '_', scan_date(7:10));
    scan_type = slist.scan_type{isub};
    cut_start = slist.cut_start(isub);
    cut_end = slist.cut_end(isub);
    usable_dynamics = num2str(slist.usable_dynamics(isub));
    
    fprintf('%i. Working on %s %s... \n', isub, subid, scan_date)
    
    sub_dir = fullfile(frawdir, subid, scan_date, 'fmri');
    
    if scan_type == 'FingerTap'
        src_dir = strcat(subid, '_', scan_type, '_216');
    elseif scan_type == 'RestState'
        src_dir = strcat(subid, '_', scan_type, '_V1');
    end
    
    dest_dir = fullfile(sub_dir, strcat(subid, '_', scan_type, '_', usable_dynamics));
    split_dir = fullfile(dest_dir, '4D_to_3D');
    mkdir(dest_dir)
    mkdir(split_dir)
    
    func_par = fullfile(sub_dir, src_dir, strcat(src_dir, ".par"));    
    func_rec = fullfile(sub_dir, src_dir, strcat(src_dir, ".rec"));    
    
    fprintf('Copying raw data... \n')
    [success, message, ~] = copyfile(func_par, split_dir);
    [success, message, ~] = copyfile(func_rec, split_dir);
   
    convert_str = sprintf('%s -f %s %s', fullfile(dcm2nii_toolbox, 'dcm2niix'), src_dir, split_dir);

    fprintf('Converting PAR/REC to 4D NIfTI... \n')
    disp(convert_str); disp(' ')
    [status, result] = system(convert_str);
    disp(result)
    
    func_nii = dir(fullfile(split_dir, '\*.nii'));
    func_nii = strcat(func_nii.folder, '\', func_nii.name);
    
    fprintf('Splitting 4D file to 3D files... \n')
    nii_list = spm_file_split(func_nii);
    merge_list = char({nii_list(cut_start:cut_end).fname});
    
    fprintf('Merging dynamics %i - %i...\n', cut_start, cut_end)
    merge_fname = fullfile(dest_dir, strcat(subid, '_', scan_type, '_', usable_dynamics, '.nii'));
    func_trunc = spm_file_merge(merge_list, merge_fname);
    
    fprintf('Saveing workspace variables... \n')
    ws_fname = fullfile(dest_dir, 'Truncate_Scan.mat');
    save(ws_fname)
    
    fprintf('Complete! \n')
    fprintf('Please check your output files to make sure everything looks right! \n')
    disp(' ')
    
    clearvars -except frawdir procdir dcm2nii_toolbox slist
end
