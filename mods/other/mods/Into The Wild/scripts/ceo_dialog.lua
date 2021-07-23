
-- Table of responses to various events.
return {
	["Script ID"] = "CEO_lmn_jungle", -- don't think this is needed, but included for completeness.
	Welcome_Message = {
		"Welcome to Meridia. The climate here is not hospitable, but it provides unique opportunities to learn about phenomena not found elsewhere.",
		"You arrived at an opportune time commander! We are mostly scientists here, and lack the firepower required to stop the Vek threat.",
		"Your #squad are certainly impressive. If you are successful in driving the Vek back, we'd be most interested in trading technology.",
		"I've theorized about the possibility of time travel. Your presence strengthens this hypothesis, and gives me hope for the future!",
		"If you are from the future, I'd be very interested in your knowledge. We cannot help much in this timeline, but hopefully we can create a technological feedback loop.",
		"We don't have much firepower to offer, but our island is hostile to everyone. Use the environment to your advantage when fighting the Vek.",
	},
	Island_Perfect = {
		"Mon ami, you have defended every objective without fail. Please accept this as our humble gift.",
		"I am blown away by your abilities, Commandant. Accept this, je t'en prie.",
		"If I hadn't seen it myself I would not have believed it. You deserve this!",
	},
	Region_Names = [[
		Tilted Shales,
        Cotyledon Complex,
        Wild Barrens,
        Boiling Expanse,
        Verdant Foothills,
        Root,
        Forestry Institute,
        Lahar Fields,
        Pyroclast Park,
        Anther Point,
        Dewy Hills,
        Tephra Expanse,
        Windy Peaks,
        Petalfall,
        Lacroix Vivarium,
        Vine Station,
        Fissure Station,
        Torrent Station,
        Vibrant Pasture,
        Agrocell Farms,
        Geohydrology Site,
        Untamed Lands,
        Nowhere,
        Paradise,
        Shambala,
        Country Roads
	]],
	
	-- Game States
	--Gamestart = {},
	--FTL_Found = {},
	--FTL_Start = {},
	--Gamestart_PostVictory = {},
	--Death_Revived = {},
	--Death_Main = {},
	Death_Response = {
		"I... I am sorry, commander...", 
		"It's hard to lose a friend...", 
		"Horreur...", 
	},
	Death_Response_AI = {
		"I'm afraid we don't have the technology to repair such an advanced AI.",
		"At least it wasn't a human life.",
		"A valiant ending for something so artificial...",
	},
	--TimeTravel_Win = {},
	Gameover_Start = {
		"Non! The power grid is damaged beyond repair. There is nothing holding them back now!",
		"This is the end...",
	},
	Gameover_Response = {
		"This... This is our fault. The experiment got out of hand. We couldn't contain it. And now the entire world will pay the price. If you can go back in time, this is your chance, commander. Adieu, mon ami.",
		"It is too late for us. Adieu, Commandant.",
		"Perhaps in another world, we will see the sun once more."	
	},
	
	-- UI Barks
	--Upgrade_PowerWeapon = {},
	--Upgrade_NoWeapon = {},
	--Upgrade_PowerGeneric = {},
	
	-- Mid-Battle
	MissionStart = {
		"Please. Prioritize protecting my people... If possible...",
		"I trust you with our lives, #squad. Do what you must!",
		"Go, #squad! Do your utmost!",
		"I believe in you.",
	},
	Mission_ResetTurn = {
		"I have the strangest feeling of deja vu!",
		"Ce n' est pas possible!... As if someone ripped through space-time continuum.",
		"Quel etrange frisson...",
		"#squad, I... have I said this before?"
	},
	MissionEnd_Dead = {
		"You've completely decontaminated the region! Well done!",
		"You have destroyed them all. Good.",
		"Va-t'en, bebittes!",
		"Our motion sensors indicate reduced Vek activity. Region decontaminated.",
	},
	MissionEnd_Retreat = {
		"They retreated faster than one would have expected.",
		"Some of the Vek have escaped their imminent deaths...",
		"You have frightened them off! That will have to do!",	
		"Yes, flee!",
	},
	
	PodIncoming = {
		"Qu'est c'est qui s'est passe?... Commander, our sensors have indicated that a pod has crashed near your location.",
		"Is this one of the time pods you have told us about?",
		"Oh?",
		"How unusual a thing you have found!",
	},
	PodResponse = {
		"I will dispatch a team of scientists to recover the pod... Of course, only if you would allow...",
		"How I wonder... Could this pod contain scientific information from a different world? ...",
		"From another world...",
		"Hard to believe this came from another land..."
	},
	--PodCollected_Self = {},
	PodDestroyed_Obs = {
		"What a pity... I will dispatch a team to investigate the wreckage. Even destroyed, it can be studied.",
		"Oh! What a shame..."
	},
	--Secret_DeviceSeen_Mountain = {},
	--Secret_DeviceSeen_Ice = {},
	--Secret_DeviceUsed = {},
	--Secret_Arriving = {},
	--Emerge_Detected = {},
	--Emerge_Success = {},
	--Emerge_FailedMech = {},
	--Emerge_FailedVek = {},

	-- Mech State
	--Mech_LowHealth = {},
	--Mech_Webbed = {},
	--Mech_Shielded = {},
	--Mech_Repaired = {},
	--Pilot_Level_Self = {},
	--Pilot_Level_Obs = {},
	--Mech_ShieldDown = {},

	-- Damage Done
	Vek_Drown = {
		"Augmented perception, enhanced locomotive ability, improved threat assessment... still can't swim.",
		"Watching them sink below fills me with a shameful joy.",
		"Water has ever nurtured humanity. Now it protects us, as well.",
	},
	Vek_Fall = {
		"My father used to tell me that 'the bigger you are the harder you fall'.",
		"Watch yourself around these pits, #squad.",
		"Gravity has claimed another.",
	},
	Vek_Smoke = {	
		"Basic survival instincts. They avoid smoke... And fire.",
		"Foolish monster, blinded and choking.",
		"Make sure you avoid the same fate, #squad.",
	},
	Vek_Frozen = {
		"Encased in ice. We could run some tests after the battle.",
		"Frozen still. Hope the icy cage won't melt too soon...",
		"'Chill out.' Ha! My father would have liked that.",
	},
	--VekKilled_Self = {},
	VekKilled_Obs = {
		"Well done!",
		"Look at it wither!",
		"One less Vek to worry about.",
		"'A confirmed kill' is what my father would have said.",
	},
	VekKilled_Vek = {
		"Their insistence to attack, even although the target is one of their own, is perplexing to say the least.",
		"Turn their own weapons against them!",
		"Turn them against each other!",
		"Foolish creatures cannot stop themselves!",
	},
	
	--DoubleVekKill_Self = {},
	DoubleVekKill_Obs = {
		"Extraordinaire!",
		"Fantastique!",
		"Exceptionnel!",
		"Yay! ... Oh, excusez-moi...",
	},
	DoubleVekKill_Vek = {
		"Their insistence to attack, even although the target is one of their own, is perplexing to say the least.",
		"Turn their own weapons against them!",
		"Turn them against each other!",
		"Well manipulated, commander!",
	},
	
	--MntDestroyed_Self = {},
	--MntDestroyed_Obs = {},
	--MntDestroyed_Vek = {},
	
	PowerCritical = {
		"Commander! S'il vous plait... Please, if the grid falls, we're done for! Defend it!",
		"Please, be careful - we're trying to hold on...",
		"I know you're doing your best...",
	},
	--Bldg_Destroyed_Self = {},
	Bldg_Destroyed_Obs = {
		"Please defend the structures, don't damage them!",
		"I thought you meant to keep our structures safe, not damage them!",
		"I thought you meant to keep our people safe, not kill them!",
		"No! Please, watch out!",
		"Mon dieu!",
	},
	Bldg_Destroyed_Vek = {
		"So many lives lost... What a horrible tragedy.",
		"S'il vous plait, commander, be more careful next time...",
		"How cruel...",
	},
	Bldg_Resisted = {
		"Please avoid taking unnecessary risks, commander...",
		"Commander! Don't tempt fate!",
		"Good heavens, my poor heart is in my throat!",
	},
	
	-- Generic Missions
	Mission_Generic_Briefing = {
		"My people lived through a lot... We tenaciously adapted with the help of science. The Vek proved to be our one weakness. Please, #squad, help us survive this tribulation as well.",
		"In the past we were a small community of scientists. In time, we have grown strong together. But not strong enough to rid ourselves of the Vek...",
		"R.S.T., Archive, Detritus and even Pinnacle rely on some of our tech to survive in the New World. Save our island, so that we may continue to support our friends.",
	},
	Mission_Generic_Success = {
		"With your help #squad, we might just survive this horrible war. Thank you.",
		"I can't deny your combat prowess in fighting the Vek, #squad. You are an inspiration to all of us.",
		"Giant mechs fighting colossal monsters for humanity's survival ... If it wouldn't be our reality, I'd call it a silly horror show."
	},
	Mission_Generic_Failure = {
		"I am afraid this was too little, too late, commander.",
		"My father was right. War is unavoidable. Neither is all the pain and suffering it brings to all involved.",
		"We shouldn't rely only on your help to fight the Vek, #squad... But we have no other choice.",
		"I know you tried hard, but sometimes having an unfavorable outcome proves to be just inevitable.",
	},
	
	-- Unsure if these should be filled in or not.
	--Mission_Survive_Briefing = {},
	--Mission_Survive_Success = {},
	--Mission_Survive_Failure = {},
	
	-- >=3 grid damage during a mission.
	Mission_ExtremeDamage = {
		"So many casualties! We value our people above everything. If you have to sacrifice an objective to save a life, I would prefer that.",
		"We know there are risks involved in our studies, but these losses are too much to endure.",
		"Was there no way to save those lives? Our people knew there were risk, but we weren't prepared for this...",
		"Some of our brightest minds were lost in that attack. This is a huge loss for Meridia.",
		"So many lives were lost today... It will take considerable time to rebuild what was lost.",
	},
	Mission_Mechs_Dead = {
		"I... I am sorry, commander. May the pilot's sacrifice not be in vain...",
		"They will be remembered for their sacrifice, always.",
		"They will live on in our memories!",
	},
	
	-- Generic Objectives
	-- Lose less than x mech health
	Mission_MechHealth_Briefing = {
		"Our resources grow thinner by the day. It would help if you could decontaminate the region with less damage inflicted on your mechs.",
		"If you can, avoid unnecessary damage - our technicians are extremely overworked as it is.",
		"Stay safe out there..."
	},
	Mission_MechHealth_Success = {
		"Our engineering teams will have to spend a minimal amount of resources to repair your mechs. Well done!",
		"My team has confirmed you're good to head out for another sortie. No repairs were needed!",
		"Well fought, #squad."
	},
	Mission_MechHealth_Failure = {
		"We aren't lacking in skilled engineers but in resources. Repairing Mechs is not cheap. Please be more careful.",
		"We will repair your mechs, but I cannot help but feel that we could have put these resources to better use...",
		"Do not worry, we will aid in the repairs..."
	},
	
	-- Lose less than x grid
	Mission_GridHealth_Briefing = {
		"My father... He always treated people as expendable human resources. I don't agree with his views. Please do your best to save my people.",
		"Keep the grid safe, #squad.",
		"Fight well, #squad."
	},
	Mission_GridHealth_Success = {
		"You saved a lot of lives today. Those families won't forget your effort. Neither will I. Merci beaucoup, #squad.",
		"Merci, #squad. You have done well.",
	},
	Mission_GridHealth_Failure = {
		"Mon Dieu! My father told me there is no war without collateral damage... But I had hoped that in this day and age I wouldn't have to witness my friends' untimely deaths.",
		"A lot of innocent lives will be buried under the rubble. But we don't have time to mourn the dead. We must go on.",
		"My heart is filled with grief, but we must all soldier on. I am sure you've done your best...",
	},
	
	-- Kill x enemies
	Mission_KillAll_Briefing = {
		"The Vek retreat when the battle goes against them, then regroup and attack again somewhere else. Wipe them out for good this time!",
		"If you rout them here, you will weaken their future attacks. Fight with tenacity!",
		"Destroy them all, #squad. They have killed far too many as it is.",
	},
	Mission_KillAll_Success = {
		"Region is decontaminated. We will be able to resume with our scientific experiments soon enough.",
		"Well done. Their blood will return to the soil and nourish it so that we may live on.",
		"Magnifique! To see them fall in droves warms my heart!",
	},
	Mission_KillAll_Failure = {
		"You let some of the Vek retreat. Unfortunately, they'll emerge again soon and attack another region.",
		"Ah, they have escaped your wrath. Dommage.",
		"...Perhaps I expect too much. I beg your pardon...",
	},
	
	-- Block x spawns
	Mission_Block_Briefing = {
		"We're studying a fragile ecosystem in this region. If too many Vek break through, the ecosystem will be devastated",
		"This region is among the few environmentally safe locations we plan to relocate our facilities to. We can't allow the Vek to destabilize the surface.",
		"Geoscans indicate several Vek specimens converging in the region. Their emergence would destabilize the surface, forcing us to retreat.",
	},
	Mission_Block_Success = {
		"Well done, #squad! The way you prevented the Vek from surfacing was impressive.",
		"Yes, stay below, monsters!",
		"The sun does not wish to see your faces, Vek! Hide in the darkness!",
	},
	Mission_Block_Failure = {
		"Excessive Vek tunneling severely destabilized the surface. This will set our research back considerably.",
		"This will play havoc with our studies. Ah, it cannot be helped...",
		"This ecosystem will collapse, I am afraid. What a shame...",
	},
	
	Mission_BossGeneric_Briefing = {
		"Our bioscans report an unknown Vek approaching our tower. We need your help, #squad!",
		"It cannot be... what is that thing!?",
		"I have never seen anything like it! Protect our tower, #squad!",
	},
	Mission_BossGeneric_Success = {
		"You have saved us commander! I've sent a team to gather the remains so we can study it. This is a great day!",
		"It went down! We are in your debt, commander!",
		"I simply cannot wait to study its remains! What wonders can be extracted from so fearsome a life form?",
	},
	Mission_BossGeneric_Tower = {
		" ... <Static> ... <Static> ... <Connection Lost> ... "
	},
	Mission_BossGeneric_Boss = {
		"That monstrous Vek survived. Without the help of your #squad, I don't know how we will endure if it returns...",
		"A shame it escaped, but you have saved us this day even so!",
		"You have driven it off! Thank you, #squad.",
	},
}