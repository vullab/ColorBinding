function convert_csv_sc(file)
    % Remove fields from csv for easier processing
    fid = fopen(file,'r');
    a={};
    count=1;
    tline=fgetl(fid);
    while ischar(tline)
        temp=tline;
        if count==1
        temp(strfind(temp,',hComp'):strfind(temp,',hComp')+length(',hComp')-1)=[];
        temp(strfind(temp,',vComp'):strfind(temp,',vComp')+length(',vComp')-1)=[];
        else
           remInds=strfind(temp,'"'); 
           temp(remInds(1)-1:remInds(2))=[];
           remInds=strfind(temp,'"'); 
           temp(remInds(1)-1:remInds(2))=[];
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