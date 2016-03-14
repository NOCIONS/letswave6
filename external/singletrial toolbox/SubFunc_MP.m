function [P_WVD, P, PARAM_est, PARAM_est_0, R_x, Rec_x, Rec_x_0, P_R_x, P_Rec_x, P_Rec_x_0, P_Res, P_Res_0] = ...
    SubFunc_MP(x, t, f, Fs, PARAM_MP)
% this sub-function is used to estimate spectrum using matching pursuit

% 'x' - the original data samples
% 'Fs' - sampling rate

% 
% fprintf(1,'=============================================== Matching Pursuit =============================================\n');
% fprintf(fid,'=============================================== Matching Pursuit =============================================\n');
% time_start = clock;


% parameters
N_T = length(t);
R_x(:,1) = x;

% iteration
for num_iter=1:PARAM_MP.Num_Iter
%     fprintf(1,' ->Iteration %d ...\n',num_iter);
%     fprintf(fid,' ->Iteration %d ...\n',num_iter);
%     time_start_iter = clock;

    % STEP 1: rough search
    gamma_max = [0, 0, 0];
    InnerProduct_Max = 0;
    
    for u_i=1:1:length(t)
        for o_i=1:1:length(f)
            for s_i=1:10
                % generate the gabor dictionaries
                gamma = [u_i, 2*pi*f(o_i)/Fs, 2.^s_i];
                [g_gamma, phi, K] = sub_gabor_dict( R_x(:,num_iter), gamma);
                InnerProduct = g_gamma*R_x(:,num_iter);
                if abs(InnerProduct_Max)<abs(InnerProduct)
                    InnerProduct_Max = InnerProduct;
                    gamma_max = [u_i, o_i, s_i];
                    g_gamma_max = g_gamma;
                    phi_max = phi;
                    K_max = K;
                end
            end
        end
    end    
   
    Rec_x_0(:,num_iter) = InnerProduct_Max*g_gamma_max;
    PARAM_est_0(num_iter,:) = [t(gamma_max(1)), f(gamma_max(2)), 2.^gamma_max(3), sign(InnerProduct_Max)*phi_max/pi/2, abs(InnerProduct_Max)*K_max];

    % STEP 2: nonlinear least-squares refining
    % algorithm 1
    opt_fun = @(PARAM) ...
        (1/sqrt(sum((exp(-pi*((t-PARAM(1))/(PARAM(3)/Fs)).^2).*cos(2*pi*PARAM(2)*(t-PARAM(1))+2*pi*PARAM(4))).^2)) * exp(-pi*((t-PARAM(1))/(PARAM(3)/Fs)).^2).*cos(2*pi*PARAM(2)*(t-PARAM(1))+2*pi*PARAM(4))) * R_x(:,num_iter)...
        * (1/sqrt(sum((exp(-pi*((t-PARAM(1))/(PARAM(3)/Fs)).^2).*cos(2*pi*PARAM(2)*(t-PARAM(1))+2*pi*PARAM(4))).^2)) * exp(-pi*((t-PARAM(1))/(PARAM(3)/Fs)).^2).*cos(2*pi*PARAM(2)*(t-PARAM(1))+2*pi*PARAM(4)))...
        - R_x(:,num_iter).';
    [PARAM_est(num_iter,1:4), resnorm] = lsqnonlin(opt_fun,PARAM_est_0(num_iter,1:end-1),[min(t),0,0,[]],[max(t),max(f),Inf,[]],PARAM_MP.optim_options);
    PARAM_est(num_iter,5) = (1/sqrt(sum((exp(-pi*((t-PARAM_est(num_iter,1))/(PARAM_est(num_iter,3)/Fs)).^2).*cos(2*pi*PARAM_est(num_iter,2)*(t-PARAM_est(num_iter,1))+2*pi*PARAM_est(num_iter,4))).^2)) ...
        * exp(-pi*((t-PARAM_est(num_iter,1))/(PARAM_est(num_iter,3)/Fs)).^2).*cos(2*pi*PARAM_est(num_iter,2)*(t-PARAM_est(num_iter,1))+2*pi*PARAM_est(num_iter,4))) * R_x(:,num_iter) ...
        * 1/sqrt(sum((exp(-pi*((t-PARAM_est(num_iter,1))/(PARAM_est(num_iter,3)/Fs)).^2).*cos(2*pi*PARAM_est(num_iter,2)*(t-PARAM_est(num_iter,1))+2*pi*PARAM_est(num_iter,4))).^2));

    % algorithm 2
    %     opt_fun = @(PARAM) PARAM(5).*exp(-pi*((t-PARAM(1))/(PARAM(3)/Fs)).^2).*cos(2*pi*PARAM(2)*(t-PARAM(1))+2*pi*PARAM(4)) - R_x(:,num_iter).';
    %     [PARAM_est(num_iter,:), resnorm] = lsqnonlin(opt_fun,PARAM_est_0(num_iter,:),[min(t),0,0,-Inf,0],[max(t),Fs/2,Inf,Inf,1e10],options);

    % reconstruct signal components
    Rec_x(:,num_iter) = PARAM_est(num_iter,5) * exp(-pi*((t-PARAM_est(num_iter,1))/(PARAM_est(num_iter,3)/Fs)).^2).*cos(2*pi*PARAM_est(num_iter,2)*(t-PARAM_est(num_iter,1))+2*pi*PARAM_est(num_iter,4));
    R_x(:,num_iter+1) = R_x(:,num_iter) - Rec_x(:,num_iter);
    P_R_x(num_iter) = sum(R_x(:,num_iter).^2);
    P_Rec_x(num_iter) = sum(Rec_x(:,num_iter).^2);
    P_Rec_x_0(num_iter) = sum(Rec_x_0(:,num_iter).^2);
    P_Res(num_iter) = sum((R_x(:,num_iter) - Rec_x(:,num_iter)).^2);
    P_Res_0(num_iter) = sum((R_x(:,num_iter) - Rec_x_0(:,num_iter)).^2);

%     % TEST DATA
%     PARAM_est = [0.00123 236.532 3.1113 2.33625 0.23116]; % for test
%     P_Res = 123.98793; P_Res_0 = 223.9879301; P_Rec_x = 364.3145; P_Rec_x_0 = 52.34256; P_R_x = 999.2112;
%     PARAM_est(2,:) = [0.00123 236.532 3.1113 2.33625 0.23116]; % for test
%     P_Res(2) = 123.98793; P_Res_0(2) = 223.9879301; P_Rec_x(2) = 364.3145; P_Rec_x_0(2) = 52.34256; P_R_x(2) = 900.2112;
%     Rec_x = 0; Rec_x_0 = 0;

    % for output
%     t_text = num2str(PARAM_est(num_iter,1)*1000,'%07.4f');
%     f_text = num2str(PARAM_est(num_iter,2),'%07.3f');
%     s_text = num2str(PARAM_est(num_iter,3),'%07.2f');
%     p_text = num2str(PARAM_est(num_iter,4),'%07.5f');
%     a_text = num2str(abs(PARAM_est(num_iter,5)),'%07.5f');
%     r_P_R_x = num2str(P_R_x(num_iter)/P_R_x(num_iter)*100,'%05.1f');     
%     if num_iter==1
%         r_P_R_x_all = num2str(P_R_x(num_iter)/P_R_x(1)*100,'%05.1f'); 
%     else
%         r_P_R_x_all = num2str(P_R_x(num_iter)/P_R_x(1)*100,'%05.2f');
%     end
%     r_P_Rec_x_0 = num2str(P_Rec_x_0(num_iter)/P_R_x(num_iter)*100,'%05.2f');      
%     r_P_Rec_x_0_all = num2str(P_Rec_x_0(num_iter)/P_R_x(1)*100,'%05.2f');
%     r_P_Res_0 = num2str(P_Res_0(num_iter)/P_R_x(num_iter)*100,'%05.2f');          
%     r_P_Res_0_all = num2str(P_Res_0(num_iter)/P_R_x(1)*100,'%05.2f');
%     r_P_Rec_x = num2str(P_Rec_x(num_iter)/P_R_x(num_iter)*100,'%05.2f');
%     r_P_Rec_x_all = num2str(P_Rec_x(num_iter)/P_R_x(1)*100,'%05.2f');
%     if abs(P_Res(num_iter)/P_R_x(num_iter)*100-100)<0.01
%         r_P_Res = num2str(P_Res(num_iter)/P_R_x(num_iter)*100,'%05.1f'); 
%     else
%         r_P_Res = num2str(P_Res(num_iter)/P_R_x(num_iter)*100,'%05.2f'); 
%     end
%     r_P_Res_all = num2str(P_Res(num_iter)/P_R_x(1)*100,'%05.2f');
% 
%     fprintf(1,'   Parameters:     |    Peak Time    |    Peak Freq    |    Time Span    |      Phase      |    Amplitude    |\n');
%     fprintf(1,'                   |    %s ms   |    %s Hz   |    %s ms   |    %s Hz   |    %s uV   |\n',...
%         t_text(1:7),f_text(1:7),s_text(1:7),p_text(1:7),a_text(1:7) );
%     fprintf(1,'   Power (uV^2):   |    Original     | Recon. w/o ref. | Resid. w/o ref. | Recon. w/ ref.  | Resid. w/ ref.  |\n');
%     fprintf(1,'                   |     %07.2f     |     %07.2f     |     %07.2f     |     %07.2f     |     %07.2f     |\n',...
%         P_R_x(num_iter),P_Rec_x_0(num_iter),P_Res_0(num_iter),P_Rec_x(num_iter),P_Res(num_iter) );
%     fprintf(1,'   Power Ratio (%%):|  %s / %s  |  %s / %s  |  %s / %s  |  %s / %s  |  %s / %s  |  \n',...
%         r_P_R_x,r_P_R_x_all,r_P_Rec_x_0,r_P_Rec_x_0_all,r_P_Res_0,r_P_Res_0_all,r_P_Rec_x,r_P_Rec_x_all,r_P_Res,r_P_Res_all);
%     fprintf(1,'   Elapsed time is %f seconds.\n',etime(clock,time_start_iter));
% 
%     fprintf(fid,'   Parameters:     |    Peak Time    |    Peak Freq    |    Time Span    |      Phase      |    Amplitude    |\n');
%     fprintf(fid,'                   |    %s ms   |    %s Hz   |    %s ms   |    %s Hz   |    %s uV   |\n',...
%         t_text(1:7),f_text(1:7),s_text(1:7),p_text(1:7),a_text(1:7) );
%     fprintf(fid,'   Power (uV^2):   |    Original     | Recon. w/o ref. | Resid. w/o ref. | Recon. w/ ref.  | Resid. w/ ref.  |\n');
%     fprintf(fid,'                   |     %07.2f     |     %07.2f     |     %07.2f     |     %07.2f     |     %07.2f     |\n',...
%         P_R_x(num_iter),P_Rec_x_0(num_iter),P_Res_0(num_iter),P_Rec_x(num_iter),P_Res(num_iter) );
%     fprintf(fid,'   Power Ratio (%%):|  %s / %s  |  %s / %s  |  %s / %s  |  %s / %s  |  %s / %s  |  \n',...
%         r_P_R_x,r_P_R_x_all,r_P_Rec_x_0,r_P_Rec_x_0_all,r_P_Res_0,r_P_Res_0_all,r_P_Rec_x,r_P_Rec_x_all,r_P_Res,r_P_Res_all);
%     fprintf(fid,'   Elapsed time is %f seconds.\n',etime(clock,time_start_iter));
    
    % if the residual power is less than the threshold
    if (P_Res(num_iter)/P_R_x(1)) < (1-PARAM_MP.MinTotalPower/100)
        break;
    end
end
% 
% fprintf(1,'============================= Matching Pursuit: Done! Total Time: %07.2f seconds. ===========================\n\n',etime(clock,time_start));
% fprintf(fid,'============================= Matching Pursuit: Done! Total Time: %07.2f seconds. ===========================\n\n',etime(clock,time_start));

%% WVD
MP_PARAM = PARAM_est;
K = size(MP_PARAM,1); % number of TF components
P = zeros(length(f),length(t),K); % TFD
for k=1:K
    x_dec(:,k) = MP_PARAM(k,5) * ...
        exp(-pi*((t-MP_PARAM(k,1))/(MP_PARAM(k,3)/Fs)).^2).*cos(2*pi*MP_PARAM(k,2)*(t-MP_PARAM(k,1))+2*pi*MP_PARAM(k,4));
    ZZ = abs(hilbert(x_dec(:,k)));
    EnvelopeRatio = 0.1;
    Length_TFC_All = ...
        1000*length(find(ZZ>EnvelopeRatio*(ZZ(find(abs(t-MP_PARAM(k,1))==min(abs(t-MP_PARAM(k,1))))))))/Fs;
    L = round(Length_TFC_All/1000*Fs);
    P(:,:,k) = sub_tfa_wvd( x_dec(:,k), [], f, Fs, round(L/2) );
    w(k) = sqrt(sum(x_dec(:,k).^2));
    P(:,:,k) = w(k)*P(:,:,k)./max(max(P(:,:,k)));
end
P_WVD = sum(real(P),3);