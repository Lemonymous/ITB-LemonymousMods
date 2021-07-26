
return function()
	local m = replaceRepair_internal
	if not m then return end
	
	LOG("Replace Repair compatibility code. One or more mods are running an outdated and unsupported version of the library.")
	
	m.RootGetTargetArea = SelfTarget.GetTargetArea
	m.OrigTipImage.Fire = Point(2,2)
end
