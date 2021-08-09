
-- requires:
-- ---------
-- modApiExt
-- LApi

-- functionlist:
-- -------------
-- track_undo_move:GetPawn()
-- returns the pawn undoing its move this frame

local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")

VERSION = "0.1.0"

if track_undo_move == nil or modApi:isVersion(VERSION, track_undo_move.version) then
	track_undo_move = track_undo_move or {
		initialized = false,
		finalized = false,
	}
	
	local pawn_undid_this_turn = nil
	
	function track_undo_move:GetPawn()
		return pawn_undid_this_turn
	end
	
	function track_undo_move:finalize()
		modApiExt:addPawnUndoMoveHook(function(mission, pawn)
			pawn_undid_this_turn = pawn
		end)
		
		modApi:addMissionUpdateHook(function(mission)
			pawn_undid_this_turn = nil
		end)
	end
	
	function track_undo_move:load()
		self.finalized = false
		
		modApi:addModsLoadedHook(function()
			if self.finalized then
				return
			end
			
			self:finalize()
			self.finalized = true
		end)
	end
end

return track_undo_move
