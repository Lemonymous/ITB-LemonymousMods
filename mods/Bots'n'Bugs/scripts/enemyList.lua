
-- create enemy list
local enemyList = easyEdit.enemyList:add("Bots'n'Bugs")

enemyList.categories = {"Core", "Core", "Core", "Leaders", "Unique", "Unique"}

enemyList:addEnemy("Leaper", "Core")
enemyList:addEnemy("Scarab", "Core")
enemyList:addEnemy("Firefly", "Core")
enemyList:addEnemy("lmn_Swarmer", "Core")
enemyList:addEnemy("lmn_Roach", "Core")

enemyList:addEnemy("lmn_Blobberling", "Unique")
enemyList:addEnemy("lmn_Spitter", "Unique")
enemyList:addEnemy("lmn_Crusher", "Unique")
enemyList:addEnemy("lmn_Wyrm", "Unique")
enemyList:addEnemy("lmn_Floater", "Unique")

enemyList:addEnemy("Jelly_Health", "Leaders")
enemyList:addEnemy("Jelly_Regen", "Leaders")
enemyList:addEnemy("Jelly_Armor", "Leaders")
enemyList:addEnemy("Jelly_Explode", "Leaders")

enemyList:addEnemy("lmn_KnightBot", "Bots")
enemyList:addEnemy("lmn_ShieldBot", "Bots")
