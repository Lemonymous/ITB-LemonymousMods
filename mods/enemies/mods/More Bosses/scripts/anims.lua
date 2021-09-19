
local mod = mod_loader.mods[modApi.currentMod]
local imagePath = "units/aliens/"
local to = "img/units/aliens/"
local from = mod.resourcePath.."img/units/"

modApi:appendAsset(to.."blobberB.png", from.."blobber.png")
modApi:appendAsset(to.."blobberBa.png", from.."blobbera.png")
modApi:appendAsset(to.."burrowerB.png", from.."burrower.png")
modApi:appendAsset(to.."burrowerBa.png", from.."burrowera.png")
modApi:appendAsset(to.."burrowerBe.png", from.."burrowere.png")
modApi:appendAsset(to.."burrowerBd.png", from.."burrowerd.png")
modApi:appendAsset(to.."centipedeB.png", from.."centipede.png")
modApi:appendAsset(to.."centipedeBa.png", from.."centipedea.png")
modApi:appendAsset(to.."crabB.png", from.."crab.png")
modApi:appendAsset(to.."crabBa.png", from.."craba.png")
modApi:appendAsset(to.."diggerB.png", from.."digger.png")
modApi:appendAsset(to.."diggerBa.png", from.."diggera.png")
modApi:appendAsset(to.."leaperB.png", from.."leaper.png")
modApi:appendAsset(to.."leaperBa.png", from.."leapera.png")
modApi:appendAsset(to.."scarabB.png", from.."scarab.png")
modApi:appendAsset(to.."scarabBa.png", from.."scaraba.png")

ANIMS.blobberB = ANIMS.blobber:new{ Image = imagePath.."blobberB.png" }
ANIMS.blobberBa = ANIMS.blobbera:new{ Image = imagePath.."blobberBa.png" }
ANIMS.blobberBe = ANIMS.blobbere:new{}
ANIMS.blobberBd = ANIMS.blobberd:new{}
ANIMS.blobberBw = ANIMS.blobberw:new{}

local y = ANIMS.burrower.PosY - 1
ANIMS.burrowerB = ANIMS.burrower:new{ Image = imagePath.."burrowerB.png", PosY = y }
ANIMS.burrowerBa = ANIMS.burrowera:new{ Image = imagePath.."burrowerBa.png", PosY = y }
ANIMS.burrowerBe = ANIMS.burrowere:new{ Image = imagePath.."burrowerBe.png" }
ANIMS.burrowerBd = ANIMS.burrowerd:new{ Image = imagePath.."burrowerBd.png" }

ANIMS.centipedeB = ANIMS.centipede:new{ Image = imagePath.."centipedeB.png" }
ANIMS.centipedeBa = ANIMS.centipedea:new{ Image = imagePath.."centipedeBa.png" }
ANIMS.centipedeBe = ANIMS.centipedee:new{}
ANIMS.centipedeBd = ANIMS.centipeded:new{}
ANIMS.centipedeBw = ANIMS.centipedew:new{}

ANIMS.crabB = ANIMS.crab:new{ Image = imagePath.."crabB.png" }
ANIMS.crabBa = ANIMS.craba:new{ Image = imagePath.."crabBa.png" }
ANIMS.crabBe = ANIMS.crabe:new{}
ANIMS.crabBd = ANIMS.crabd:new{}
ANIMS.crabBw = ANIMS.crabw:new{ Height = 1 }

ANIMS.diggerB = ANIMS.digger:new{ Image = imagePath.."diggerB.png" }
ANIMS.diggerBa = ANIMS.diggera:new{ Image = imagePath.."diggerBa.png" }
ANIMS.diggerBe = ANIMS.diggere:new{}
ANIMS.diggerBd = ANIMS.diggerd:new{}
ANIMS.diggerBw = ANIMS.diggerw:new{}

ANIMS.leaperB = ANIMS.leaper:new{ Image = imagePath.."leaperB.png" }
ANIMS.leaperBa = ANIMS.leapera:new{ Image = imagePath.."leaperBa.png" }
ANIMS.leaperBe = ANIMS.leapere:new{}
ANIMS.leaperBd = ANIMS.leaperd:new{}
ANIMS.leaperBw = ANIMS.leaperw:new{}

ANIMS.scarabB = ANIMS.scarab:new{ Image = imagePath.."scarabB.png" }
ANIMS.scarabBa = ANIMS.scaraba:new{ Image = imagePath.."scarabBa.png" }
ANIMS.scarabBe = ANIMS.scarabe:new{}
ANIMS.scarabBd = ANIMS.scarabd:new{}
ANIMS.scarabBw = ANIMS.scarabw:new{}
