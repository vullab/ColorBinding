function [hComps vComps]=convert_csv_sc2(file)
    % Remove fields from csv for easier processing
    % v2-Return refi, hcomp, and vcomp
    fid = fopen(file,'r');
    a={};
    count=1;
    tline=fgetl(fid);
    hComps=nan(400,25);
    vComps=nan(400,25);
    while ischar(tline)
        temp=tline;
        if count==1
        temp(strfind(temp,',hComp'):strfind(temp,',hComp')+length(',hComp')-1)=[];
        temp(strfind(temp,',vComp'):strfind(temp,',vComp')+length(',vComp')-1)=[];
        else
           remInds=strfind(temp,'"'); 
           vComp=temp(remInds(1)-1:remInds(2));
           vComp=str2num(vComp(4:end-2));
           vComps(count-1,:)=vComp;
           temp(remInds(1)-1:remInds(2))=[];
           remInds=strfind(temp,'"'); 
           hComp=temp(remInds(1)-1:remInds(2));
           hComp=str2num(hComp(4:end-2));
           hComps(count-1,:)=hComp;
           temp(remInds(1)-1:remInds(2))=[];
           
           allComps{count-1,1}=hComp;
           allComps{count-1,2}=vComp;
        end
        a{count}=temp;
        count=count+1;
        tline=fgetl(fid);
    end
    fclose(fid);
    
    file2=file;
    file2(length(file)-4)='2';
    fid2 = fopen(file2, 'w');
    for i=1:length(a)
        
        fprintf(fid,strcat(a{i},'\n'));
        
    end