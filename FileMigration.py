# -*- coding: utf-8 -*-
"""
Created on Fri Jun  3 10:38:38 2022

@author: HsuanWei
"""

import pandas as pd
import os, glob, shutil

src_dir_ftap = "//kki-gspnas1/dcn_data$/Stacy/BRAINY_fMRI_preproc_ftap"
src_dir_rs = "//kki-gspnas1/dcn_data$/Stacy/BRAINY_fMRI_preproc_rs"

#Please change the dest_dir to your folder of interest
dest_dir = "//kki-gspnas1/dcn_data$/Stacy/Scans/BRAINY/1_Derivatives/Adrian_DTS_RestingState"
#dest_dir = "//kki-gspnas1/dcn_data$/Stacy/Scans/BRAINY/1_Derivatives/Adrian_UFOV_RestingState"

df = pd.read_csv(dest_dir + "/SubjectList_DTS.csv")
#df = pd.read_csv(dest_dir + "/SubjectList_UFOV.csv")

count = 1 
#for ind in  range(0,1):
for ind in df.index:
    print("{}. Working on ".format(count) + df["subject_ID"][ind] + " " + df["session_date"][ind] + "...")
    
    print("Creating subject folders...")
    #Set up folder names    
    sub_dir = os.path.join(dest_dir, df["subject_ID"][ind], df["session_date"][ind], "func")
    os.makedirs(sub_dir, exist_ok = True)
    
    if df["ftap_usable_time"][ind] >= 2:
        print("Finger tapping data is USABLE...")
        src_ftap_QC = glob.glob(src_dir_ftap + "/" + df["subject_ID"][ind] + "/" + df["session_date"][ind] + "/*QC*")
        
        print("\nCopying ftap QC files...")
        for file in src_ftap_QC:
            print(file[-40:])
            shutil.copy(file, sub_dir)
        
        print("\nCopying ftap pre-processed data...")
        src_ftap_data = os.path.join(src_dir_ftap, df["subject_ID"][ind], df["session_date"][ind], "func")
        dest_ftap_data = os.path.join(dest_dir, df["subject_ID"][ind], df["session_date"][ind], "func", "ftap")
        
        try: 
            shutil.copytree(src_ftap_data, dest_ftap_data)
            print("Success!\n")
        except OSError as error : 
            print(error) 
            print("Fail\n")    
        
    if df["rs_usable_time"][ind] >= 2:
        print("Resting-state data is USABLE...")
        src_rs_QC = glob.glob(src_dir_rs + "/" + df["subject_ID"][ind] + "/" + df["session_date"][ind] + "/*QC*")
        
        print("\nCopying rs QC files...")
        for file in src_rs_QC:
            print(file[-40:])
            shutil.copy(file, sub_dir)
        
        print("\nCopying rs pre-processed data...")
        src_rs_data = os.path.join(src_dir_rs, df["subject_ID"][ind], df["session_date"][ind], "func")
        dest_rs_data = os.path.join(dest_dir, df["subject_ID"][ind], df["session_date"][ind], "func", "rest")
        
        try: 
            shutil.copytree(src_rs_data, dest_rs_data)
            print("Success!\n")
        except OSError as error : 
            print(error) 
            print("Fail\n")    
        
    count = count + 1