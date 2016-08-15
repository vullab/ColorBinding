paths = {'../../Eds_experiments/multi-color-binding-crosses/data/', ...
    '../../Eds_experiments/multi-color-binding-circles/data/'};

names = {'crosses', 'circles'};

for T = [1:2]
    
    files = dir(sprintf('%s*_1.txt',paths{T}));
    nsubs(T) = 0;
    
    for fi = [1:length(files)]
        curfile = fopen(sprintf('%s%s', paths{T}, files(fi).name));
        discard = fgetl(curfile);
        
        q = textscan(curfile,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ', 'delimiter', ',');
        if((q{14}(1) == T) & (length(q{14})>100))
            nsubs(T) = nsubs(T)+1;
            z{T}{nsubs(T)} = q;
        end
        fclose(curfile);
    end
    
    % columns!
    %  1    cue-length
    %  2    ms-precue
    %  3    resp-v-hv
    %  4    ms-st-cue
    %  5    nitems
    %  6    resp-h-pos
    %  7    resp-v-pos
    %  8    ms-stimon
    %  9    resp-h-hv
    % 10    cue-loc-int
    % 11    cue=loc-x
    % 12    cue-loc-y
    % 13    radius
    % 14    bars-or-spot
    % 15    npractice
    % 16    ntrials
    
    resps{T} = zeros(5, 5, 2, 2, nsubs);
    r10{T} = zeros(10, 10, nsubs);
    r10x{T} = zeros(10, 10, nsubs);
    
    for s = [1:nsubs(T)]
        
        hpos = z{T}{s}{6};
        vpos = z{T}{s}{7};
        h_hv = z{T}{s}{9};
        v_hv = z{T}{s}{3};
        
        idxbad = (hpos == vpos) & (h_hv == v_hv);
        badap(s) = sum(idxbad)./length(idxbad);
        %
        %     hpos(idxbad) = [];
        %     vpos(idxbad) = [];
        %     h_hv(idxbad) = [];
        %     v_hv(idxbad) = [];
        
        h_c = h_hv==1;
        v_c = v_hv==2;
        
        
        varhmarg(s) = var(hpos);
        varvmarg(s) = var(vpos);
        q = cov(hpos,vpos);
        covhvmarg(s) = q(1,2);
        mhhv(s) = mean(h_hv);
        mvhv(s) = mean(v_hv);
        
        % divided into things
        idx12 = h_hv==1 & v_hv==2;
        idx21 = h_hv==2 & v_hv==1;
        idx22 = h_hv==2 & v_hv==2;
        
        % 11
        for h = [1:2]
            for v = [1:2]
                idx = h_hv==h & v_hv==v;
                
                varh{h}{v}(s) = var(hpos(idx));
                varv{h}{v}(s) = var(vpos(idx));
                q = cov(hpos(idx),vpos(idx));
                covhv{h}{v}(s) = q(1,2);
                n(h,v,s) = sum(idx);
            end
        end
        
        
        for i = [1:length(hpos)]
%             %         resps(hpos(i)+3, vpos(i)+3, h_hv(i)+1, v_hv(i)+1, s) = resps(hpos(i)+3, vpos(i)+3, h_hv(i)+1, v_hv(i)+1, s)+1;
%             idxh = hpos(i)+3 + 5.*(h_c(i));
%             idxv = vpos(i)+3 + 5.*(v_c(i));
%             
%             r10{T}(idxh, idxv,s) = r10{T}(idxh,idxv,s) +1;
            
            idxh = hpos(i)+3 + 5.*(h_hv(i)-1);
            idxv = vpos(i)+3 + 5.*(v_hv(i)-1);
            
            r10{T}(idxh, idxv,s) = r10{T}(idxh,idxv,s) +1;
        end
    end
    
    r10x{T} = sum(r10{T},3);
    p10x{T} = sum(r10x{T},3)./sum(r10x{T}(:));
    
end