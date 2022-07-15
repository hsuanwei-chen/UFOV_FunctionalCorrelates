# Functional neural correlates of useful field of view (UFOV) performance in youth clinically recovered from concussion and uninjured controls 

This project is used to find neural correlates of Useful Field of View (UFOV) and Dual Task Screen (DTS) with the BRAINY finger tapping and resting state scans

To derive connectivity values, run:
1) FileMigration.py
2) TruncateScan.m
3) batch_propreprocess_list.m (from CNIR-fmri-preproc-toolbox)
4) PostProcessList.py
5) batch_postprocess_list.m (from CNIR-fmri-preproc-toolbox)
6) FD_calculation.m
7) batch_FunctionalConnectivity_{AtlasName}.m

To generate connectivity heatmaps prior to averaging connectivity values, run: 
1) Plot_meanConnNetworkHeatmap_{7Networks or 400Parcels}

To average the connectivity values per subject-session, run:
1) ConcatenateFC_{7Networks or 400Parcels}

To plot the connectivty heatmaps after averaging connectivity values, run:
1) Plot_Concat_meanConnNetworkHeatmap_{7Networks or 400Parcels}

Other:
- meanConnNetworkHeatmap_by{Network or parcel}
