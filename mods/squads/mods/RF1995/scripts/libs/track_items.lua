
-- requires:
-- ---------
-- modApiExt
-- LApi
-- hooks

-- functionlist:
-- -------------
-- track_items:addItemCreatedHook(fn)
-- fn(mission, loc, created_item)

-- track_items:addItemRemovedHook(fn)
-- fn(mission, loc, removed_item)

-- track_items:addItemChangedHook(fn)
-- fn(mission, loc, previous_item, this_item)

-- track_items:GetItems()
-- returns a table with key/value pairs of point_index/item_name

local mod = mod_loader.mods[modApi.currentMod]
local hooks = require(mod.scriptPath .."libs/hooks")

hooks:new("itemCreated")
hooks:new("itemRemoved")
hooks:new("itemChanged")

VERSION = "0.1.0"

if track_items == nil or modApi:isVersion(VERSION, track_items.version) then
	track_items = track_items or {
		initialized = false,
		finalized = false,
		items_label = "item_detection_tracked_items"
	}
	
	track_items.master_mod = mod.id
	
	function track_items:addItemCreatedHook(fn) hooks:addItemCreatedHook(fn) end
	function track_items:addItemRemovedHook(fn) hooks:addItemRemovedHook(fn) end
	function track_items:addItemChangedHook(fn) hooks:addItemChangedHook(fn) end
	function track_items:GetItems()
		local mission = GetCurrentMission()
		
		if mission == nil then
			return {}
		end
		
		mission[self.items_label] = mission[self.items_label] or {}
		
		return shallow_copy(mission[self.items_label])
	end
	
	function track_items:finalize()
		modApi:addMissionUpdateHook(function(mission)
			mission[self.items_label] = mission[self.items_label] or {}
			
			local size = Board:GetSize()
			for x = 0, size.x - 1 do
				for y = 0, size.y - 1 do
					local loc = Point(x, y)
					local pid = p2idx(loc)
					
					local item_prev_turn = mission[self.items_label][pid]
					local item_this_turn = Board:GetItemName(loc)
					
					mission[self.items_label][pid] = item_this_turn
					
					if item_prev_turn ~= item_this_turn then
						if item_prev_turn and item_this_turn then
							hooks:fireItemChangedHooks(mission, loc, item_prev_turn, item_this_turn)
						end
						
						if item_this_turn == nil then
							hooks:fireItemRemovedHooks(mission, loc, item_prev_turn)
						else
							hooks:fireItemCreatedHooks(mission, loc, item_this_turn)
						end
					end
				end
			end
		end)
	end
--[[
	function track_items:init()
		if self.initialized then
			return
		end
		
		self.initialized = true
		
		-- initialize code --
	end
]]
	function track_items:load()
		if self.master_mod == mod.id then
			self.finalized = false
			
			modApi:addModsLoadedHook(function()
				if self.finalized then
					return
				end
				
				self:finalize()
				self.finalized = true
			end)
			
			modApi:addTestMechExitedHook(function(mission)
				mission[self.items_label] = nil
			end)
		end
	end
end

return track_items
