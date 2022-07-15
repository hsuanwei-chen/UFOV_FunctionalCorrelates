# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 11:33:11 2022

@author: HsuanWei
"""

import pandas as pd
import glob

dest_dir = "//kki-gspnas1/dcn_data$/Stacy/Scans/BRAINY/1_Derivatives/UFOV_FunctionalCorrelates"

ftap_ses = glob.glob(dest_dir + "/*/*/func/ftap")
rest_ses = glob.glob(dest_dir + "/*/*/func/rest")

all_ses = ftap_ses + rest_ses
all_ses.sort()

for i in range(len(all_ses)):
    all_ses[i] = all_ses[i][-32:]
    all_ses[i] = all_ses[i].split("\\")

df = pd.DataFrame(all_ses, columns=["subject_id", "sess_date", "func", "task_dir"])

dest_fname = dest_dir + "/ScansToPostProcess.csv"
df.to_csv(dest_fname, index = False)
