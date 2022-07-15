%The purpose of this scirpt is to create a summary of the motion parameters
%for all the participants
clear; clc;

%Define file path
procdir = '\\kki-gspnas1\DCN_data$\Stacy\Scans\BRAINY\1_Derivatives\UFOV_FunctionalCorrelates';

%Read in the subject list
slist = readtable(fullfile(procdir, 'ScansToPostProcess.csv'));

istart = 1;
iend = length(slist.subject_id);

%Initialize variables to save summary values
motion_header = {'subject_id', 'sess_date', 'task_dir', 'x_mean', 'y_mean', 'z_mean', ...
    'pitch_mean', 'roll_mean', 'yaw_mean', 'FD_mean', 'FD_max'};
group_motion_tbl = array2table(zeros(0, length(motion_header)));
group_motion_tbl.Properties.VariableNames = motion_header;
        
for isub = istart:iend
    %Extract the ID, session date, and type of scan
    ID = slist.subject_id{isub};
    sess_date = slist.sess_date{isub};
    task_dir = slist.task_dir{isub};
    
    %Print what subject session is currently being analyzed
    fprintf('%i. Generating motion summary for %s %s %s... \n', isub, ID, sess_date, task_dir)
    
    %rename_task: e.g., task-rest_bold or task-ftap_bold; processing script will copy
    %       and rename func_files to procdir/ID using the following convention -
    %       sub-ID/sess-DateOfSession/func/task_dir/run-??/sub-ID_sess-DateOfSession_rename_task_run-??.nii,
    %       where run number is determined by the order of func_files
    if task_dir == 'ftap'
        rename_task = 'task-ftap_bold';
    elseif task_dir == 'rest'
        rename_task = 'task-rest_bold';
    end
   
    %Locate the motion parameter file
    rp_fname = strcat('rp_a', ID, '_', sess_date, '_', rename_task, '_run-01.txt');
    rp_file = dir(fullfile(procdir, ID, sess_date, 'func', task_dir, 'run-01', rp_fname));
        
    %Load motion parameter file 
    param = load(fullfile(rp_file.folder, rp_file.name));
    trans = param(:, 1:3);
    rot = param(:, 4:6)*180/pi;  %convert from radian to degrees
        
    %Find the mean of translational and rotational parameters
    fprintf('Calculating translational and rotational mean... \n');       
    trans_mean = num2cell(mean(trans));
    rot_mean = num2cell(mean(rot));
        
    %Find mean FD and max FD
    %Please note that this is FD calculated after slice time correction
    fprintf('Calculating mean and max FD... \n');        
    FD = fmri_FD(fullfile(rp_file.folder, rp_file.name));
    FD_mean = mean(FD);
    FD_max = max(FD);
        
    %Aggregate motion summary for individual
    motion_sum = {ID, sess_date, task_dir, trans_mean{1:3}, rot_mean{1:3}, FD_mean, FD_max};
    motion_tbl = cell2table(motion_sum);
    motion_tbl.Properties.VariableNames = motion_header;
    group_motion_tbl = [group_motion_tbl; motion_tbl];
    
    fprintf('Done! \n');   
end

%Write output into excel
dest_fname = strcat(procdir, '\MotionSummary_table.csv');
writetable(group_motion_tbl, dest_fname)
        
function FD = fmri_FD(rp_file)
%Function to calculate Framewise Displacement (FD) (Power et al., 2012)from
%the six realignment parameters.  FD is calculated by summing the absolute
%value of the differenced (time t?time t?1) translational realignment
%parameters and the three differenced rotational parameters, which are
%converted from radians to millimeters by assuming a brain radius of 50 mm.
%
%Usage: FD = fmri_FD(rp_file)
%where  rp_file is the path/file name containing the realignment parameters
%       in columns (such as what is obtained from spm_realign or mcflirt)

dat = load(rp_file); %Load motion parameter file
dat = dat(:, 1:6); %Only include columns 1-6
order = 1;
diff_dat = abs([[0 0 0 0 0 0]; diff(dat, order, 1)]); %Takes the difference of the val
% 	Multiply by 50mm brain;
diff_dat(:,4:6) = diff_dat(:,4:6) * 50;
FD = sum(diff_dat, 2);
end