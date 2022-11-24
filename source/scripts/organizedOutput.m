output = table();
st = [];
% obscode = 

for i = 1: size(rec,2)
    work = rec(1,i).work;
    work.updateAllAvailIndex();
    prn = work.prn;
    obs_code = work.obs_code;
    obs = work.obs;
    %     old_obs = work.old_obs;
    avail_idx = work.sat.avail_index;
    work.time.toMatlabTime;
    dtS = work.sat.dtS;
    ddtS = work.sat.ddtS;
    epoch = datetime(work.time.mat_time,'ConvertFrom','datenum');
    
    %     [dts, ddts] = work.getDtS();
    rel_clk_corr = work.sat.rel_clk_corr;
    sat = work.sat;
    sat_cache = work.sat_cache;
    
    for t = 1: length(epoch)
        validSat = find(avail_idx(t,:));
        for j = 1 : length(validSat)
            obs_col = find(prn == validSat(j));
            C1_idx = contains(string(obs_code(obs_col, :)),'C1');
            L1_idx = contains(string(obs_code(obs_col, :)),'L1');
            D1_idx = contains(string(obs_code(obs_col, :)),'D1');
            S1_idx = contains(string(obs_code(obs_col, :)),'S1');
            C2_idx = contains(string(obs_code(obs_col, :)),'C2');
            L2_idx = contains(string(obs_code(obs_col, :)),'L2');
            D2_idx = contains(string(obs_code(obs_col, :)),'D2');
            S2_idx = contains(string(obs_code(obs_col, :)),'S2');
%             if(any(C1_idx) && any(L1_idx) && any(D1_idx) && any(S1_idx) ...
%                     && any(C2_idx) && any(L2_idx) && any(D2_idx) && any(S2_idx))
            if(any(C1_idx) && any(L1_idx) && any(D1_idx) && any(S1_idx))
                if i == 1 && isempty(st)
                    st = epoch(t);
                end
                element = table();
                element.time = epoch(t);
                element.epoch = seconds(epoch(t) - st);
                element.satId = validSat(j);
%                             element.P1 = old_obs(obs_col(find(C1_idx, 1)), t);
%                             element.L1 = old_obs(obs_col(find(L1_idx, 1)), t);
                element.P1_corr = obs(obs_col(find(C1_idx, 1)), t);
                element.L1_corr = obs(obs_col(find(L1_idx, 1)), t);
                element.D1 = obs(obs_col(find(D1_idx,1)), t);
                element.S1 = obs(obs_col(find(S1_idx,1)), t);
%                             element.P2 = old_obs(obs_col(find(C2_idx,1)), t);
%                             element.L2 = old_obs(obs_col(find(L2_idx,1)), t);
                if(any(C2_idx) && any(L2_idx) && any(D2_idx) && any(S2_idx))
                    element.P2_corr = obs(obs_col(find(C2_idx,1)), t);
                    element.L2_corr = obs(obs_col(find(L2_idx,1)), t);
                    element.D2 = obs(obs_col(find(D2_idx,1)), t);
                    element.S2 = obs(obs_col(find(S2_idx,1)), t);
                else
                    element.P2_corr = 0;
                    element.L2_corr = 0;
                    element.D2 = 0;
                    element.S2 = 0;
                end
                element.dts = dtS(t, validSat(j));
                element.ddts = ddtS(t, validSat(j));
                element.rel_clk_corr = rel_clk_corr(t, validSat(j));
%                 element.dt = work.dt(t);
                element.az = sat.az(t, validSat(j));
                element.el = sat.el(t, validSat(j));
                id = sat_cache.go_id == validSat(j);
                element.range = sat_cache.range(id, t);
                if element.range == 0
                    warning('%f epoch, prn %d, the %d obs range is zero', element.epoch, element.satId, size(output,1));
                    continue;
                end
                satPosList = sat_cache.xs_loc_t{1, id};
                satPos = satPosList(sum(sat_cache.range(id, 1:t)~=0), :);
                satV = sat_cache.vs{1, id}(sum(sat_cache.range(id, 1:t)~=0), :);
                element.satrelx = satPos(1);
                element.satrely = satPos(2);
                element.satrelz = satPos(3);
                element.satvx = satV(1);
                element.satvy = satV(2);
                element.satvz = satV(3);
                output = [output; element];
            end
        end
        
    end
    
end