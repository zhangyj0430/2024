clc;clear;
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/seed_Mask';
data_dir='/home1/zhangyj/Desktop/MDD/MDD_GBC/2_BetGroup_Analysis/1_ComBet_GBCmap/ComBet_data_D2_GSR';
Mask=[mask_dir,'/AAL90_3mm_mask.nii'];
mask=logical(y_ReadAll(Mask));

str={'HC','MDD'};
DD=[];
hc_dirs=dir([data_dir,'/*HC*.nii']);
mdd_dirs=dir([data_dir,'/*MDD*.nii']);
file={hc_dirs,mdd_dirs};
var_DD=[];
group_D=[];
mean_dep=[];
color={[49,130,189]./255,[222,45,38]./255};


for i=1:length(file{1,1})
    D1{i,1}=[file{1,1}(i).folder,'/',file{1,1}(i).name] ;
end
[ A1,~,~,header]=y_ReadAll(D1);
for i=1:length(file{1,2})
    D2{i,1}=[file{1,2}(i).folder,'/',file{1,2}(i).name] ;
end
[ A2,~,~,header]=y_ReadAll(D2);
A={A1,A2};
for m=1:2
    data=reshape(A{1,m},[],size(A{1,m},4));
    data=data(mask,:);
    group_D{1,m}=mean(data,1);
    group_D{2,m}=str{1,m};
    var_D{1,m}=var(data,1);
    var_D{2,m}=str{1,m};
    mean_Dep(:,m)=mean(data,2);
    tep=zeros(size(mask));
    tep(mask) = mean_Dep(:,m);
    y_Write(tep,header,['Mean_',str{1,m}]);
    h=histfit(mean_Dep(:,m),50,'kernel');
    alpha(0.5)
    h(1).FaceColor=color{1,m};
    h(2).Color =color{1,m};
    hold on
end
save('mean_Dep.mat','mean_Dep');
save('meanGBC.mat','group_D');
save('varGBC.mat','var_D');

SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_GBC/subject_info/SubInfo.xlsx');
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
cov_hc=[SubInfo.age(ind_hc),SubInfo.sex(ind_hc),SubInfo.FD(ind_hc)];
cov_mdd=[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd),SubInfo.FD(ind_mdd)];
[t_meanGBC,p_meanGBC]=y_TTest2Cov(group_D{1,1},group_D{1,2},cov_hc,cov_mdd);
[t_varGBC,p_var_GFBC]=y_TTest2Cov(var_D{1,1},var_D{1,2},cov_hc,cov_mdd);
save ttest_meanGBC&varGBC.mat t_meanGBC p_meanGBC t_varGBC p_var_GFBC
    

