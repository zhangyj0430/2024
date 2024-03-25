% Extract the Seed Time Courses
clc;clear;
workingDir1='/home1/zhangyj/Desktop/MDD/Data/D2_GSR_S';
sublist1=dir(workingDir1);
ind=[sublist1(:).isdir];
sublist1=sublist1(ind);
sublist1=sublist1(3:end);
n_sub1=size(sublist1,1);


SeedSeries = [];
% file=dir('/Volumes/MDD/Depression_Multicenter/SeedFC/test/');
[ROI1mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI1_precuneus_mask.nii');
[ROI2mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI2_frontal_mask.nii');
[ROI3mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI3_L_central_mask.nii');
[ROI4mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI4_R_central_mask.nii');
[ROI5mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI5_L_FFG_mask.nii');
[ROI6mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI6_R_FFG_mask.nii');
[ROI7mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI7_R_angular_mask.nii');
[ROI8mask,~,~,~] =y_ReadAll('controlFD_twotail_ROI8_L_angular_mask.nii');
ROIDef{1}=ROI1mask;
ROIDef{2}=ROI2mask;
ROIDef{3}=ROI3mask;
ROIDef{4}=ROI4mask;
ROIDef{5}=ROI5mask;
ROIDef{6}=ROI6mask;
ROIDef{7}=ROI7mask;
ROIDef{8}=ROI8mask;
MaskData=y_ReadAll('/home1/zhangyj/Desktop/MDD/AnalysisData/GBC_AAL90_update/seed_Mask/AAL90_3mm_mask.nii');
MaskData = double(logical(MaskData));
ROI={'D2_ROI1_','D2_ROI2_','D2_ROI3_','D2_ROI4_','D2_ROI5_','D2_ROI6_','D2_ROI7_','D2_ROI8_'};
for sub=1:n_sub1
    sublist1(sub).name
    file=dir([sublist1(sub).folder,'/',sublist1(sub).name,'/*nii']);
    [AllVolume,~,~,~] =y_ReadAll([file.folder,'/',file.name]);
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
    AllVolume=reshape(AllVolume,[],size(AllVolume,4))';  
    MaskDataOneDim=reshape(MaskData,1,[]);
    MaskIndex = find(MaskDataOneDim);   
    AllVolume_inmask=AllVolume(:,MaskIndex);   
    sAllVolume = AllVolume_inmask-repmat(mean(AllVolume_inmask),size(AllVolume_inmask,1),1);
    sAllVolumeSTD= squeeze(std(sAllVolume, 0, 1));
    sAllVolumeSTD(find(sAllVolumeSTD==0))=inf;
    
    for iROI=1:8 %size(ROIDef,2)
        MaskROI = ROIDef{iROI};
        MaskROI=reshape(MaskROI,1,[]);
        MaskROI=MaskROI(MaskIndex); %Apply the brain mask
        SeedSeries = mean(AllVolume_inmask(:,find(MaskROI)),2);  
        
        SeedSeries=SeedSeries-repmat(mean(SeedSeries),size(SeedSeries,1),1);
        SeedSeriesSTD=squeeze(std(SeedSeries,0,1));
        
        Header.pinfo = [1;0;0];
        Header.dt    =[16,0];
       
        OutputName=['/home1/zhangyj/Desktop/MDD/MDD_GBC/3_seed_FC/1_seedFC_calculate/seedFC_map/',sublist1(sub).name,'.nii'];
        
        FC=SeedSeries'*sAllVolume/(nDimTimePoints-1);
        FC=(FC./sAllVolumeSTD)/SeedSeriesSTD;

        FCBrain=zeros(size(MaskDataOneDim));
        FCBrain(1,MaskIndex)=FC;
        FCBrain=reshape(FCBrain,nDim1, nDim2, nDim3);
        zFCBrain = (0.5 * log((1 + FCBrain)./(1 - FCBrain))) .* (MaskData~=0);
        
        [pathstr, name, ext] = fileparts(OutputName);
        y_Write(FCBrain,Header,[fullfile(pathstr,[ROI{iROI},name, ext])]);
        y_Write(zFCBrain,Header,[fullfile(pathstr,['z',ROI{iROI},name, ext])]);
    end
end


