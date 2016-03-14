function out_dataset=CLW_run_script(dataset,script_list,update_pointers)
%CLW_run_script

%argument parsing
if nargin<1;
    error('dataset is required');
end;
if nargin<2;
    error('script_list is required');
end;
if nargin<3;
    update_pointers=[];
end;

%process
for script_pos=1:length(script_list);
    %configuration
    configuration=script_list(script_pos).configuration;
    if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Script entry ' num2str(script_pos) ' : ' configuration.gui_info.name],1,0); end;
    %process function
    eval_st=[configuration.gui_info.function_name '(''process'',configuration,dataset,update_pointers)'];
    [configuration,dataset]=eval(eval_st);
end;
%out_dataset
out_dataset=dataset;

end

