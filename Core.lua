
function execute_macro(macro, fnct)
	local evaluation_result, target, param, target_type = parse_macro(macro)
	
	if not evaluation_result then
		return
	end
	
	fnct(param, target, target_type)
end