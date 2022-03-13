
-- create enemy list
local enemyList = modApi.enemyList:add("Meridia")

enemyList.categories = {"Core", "Core", "Core", "Unique", "Unique", "Unique"}

enemyList:addEnemy("lmn_Sprout", "Core")
enemyList:addEnemy("lmn_Puffer", "Core")
enemyList:addEnemy("lmn_Springseed", "Core")
enemyList:addEnemy("lmn_Chomper", "Core")
enemyList:addEnemy("lmn_Sunflower", "Core")

enemyList:addEnemy("lmn_Chili", "Unique")
enemyList:addEnemy("lmn_Beanstalker", "Unique")
enemyList:addEnemy("lmn_Bud", "Unique")
enemyList:addEnemy("lmn_Cactus", "Unique")
enemyList:addEnemy("lmn_Infuser", "Unique")
