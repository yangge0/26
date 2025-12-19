local Sheng = GameMain:GetMod("Lua_Sheng");
local Death = GameMain:GetMod("Lua_Death");
local YaoShou = GameMain:GetMod("_LogicMode"):CreateMode("Lua_CallYaoShouAtk")
local YingEr = GameMain:GetMod("_ModifierScript"):GetModifier("YINGERSHI");
local XChat = GameMain:GetMod("XChat");
local shengercao = {{0,0,"未生产",{"未知",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}}}}
local YaoShouID = {}
local time = {};
local flag = nil;
local npc1 = nil;
local npc2 = nil;

---------------------------------------------------------------------------------------------存档

function Sheng:OnBeforeInit()
local bnt = CS.XiaWorld.MenuData()
bnt.Name = "交流"
bnt.Desc = "尝试和这位道友进行交流"
bnt.Story = "Story_JiaoLiu"
bnt.Cost = "30"
bnt.Icon = "res/Sprs/ui/icon_hand"
bnt.Appoint = "3"
if CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts == nil then
CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts = {}
CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts:Add(bnt)
else
local count = CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts.Count
flag = 0;
for i = 0 , count - 1 , 1 do
if CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts[i].Name == "交流" then
flag = 1;
end
end
if flag == 0 then
CS.XiaWorld.ThingMgr.Instance:GetDef(CS.XiaWorld.g_emThingType.Npc,"NpcBase").StoryBnts:Add(bnt)
end
end
end

function Sheng:OnInit()
OrphanageWindow = GameMain:GetMod("Windows"):CreateWindow("OrphanageWindow");
end


function Sheng:OnStep(dt)
	if shengercao[1] == nil then
		shengercao = {{0,0,"未生产",{"未知",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}}}}
	end
	for k,v in ipairs(shengercao) do
	        if type(shengercao[k][3]) == "number" then
			shengercao[k][3] = shengercao[k][3] + dt;
		if shengercao[k][3] >=  12500 then
			shengercao[k][3] = "生产完";
			Sheng:shenger(k);
			table.remove(shengercao,k)
		end
	end
	end
end

function Sheng:OnSave()
	local tbSave = {["Index1"] = shengercao , ["Index2"] = YaoShouID };
	return tbSave;
end

function Sheng:OnLoad(tbLoad)
	if tbLoad ~= nil then
		shengercao = tbLoad["Index1"];
		YaoShouID = tbLoad["Index2"];
	end
end

function Sheng:ChangeCao(n,a,b,c,d)
local lenth = #shengercao
shengercao[n][1] = a;
shengercao[n][2] = b;
shengercao[n][3] = c;
shengercao[n][4] = d;
shengercao[lenth+1] = {0,0,"未生产",{"未知",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}}}
end

function Sheng:PrintTable()
for k,v in ipairs(shengercao) do
print(v[1],v[2],v[3],v[4])
end
end

function YingEr:Step(modifier, npc, dt)
if time[npc.ID] == nil then
time[npc.ID] = 0;
end
time[npc.ID] = time[npc.ID] + dt;
if time[npc.ID] >= 600 then
time[npc.ID] = 0;
local itemThing = ThingMgr:AddItemThing(0, "Item_Shit", Map, 1, false);
itemThing.Author = npc:GetName();
Map:DropItem(itemThing, npc.Key, false, false, false, false, 0, false);
end
end


--GameMain:GetMod("Lua_Death"):PrintTable()
--GameMain:GetMod("Lua_Death"):TouTai(1)
--GameMain:GetMod("Lua_Sheng"):ChangeCao(1,8810,8819,12480,{"五胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}})
--GameMain:GetMod("Lua_Sheng"):PrintTable()
---------------------------------------------------------------------------生死簿模块
local shengsibu = {{"轮回剩余时间","姓","名","种族","性别","境界","称号","死因"}}
local temptime = 0;

function Death:OnEnter()
GameMain:GetMod('_Event'):RegisterEvent(CS.XiaWorld.g_emEvent.NpcDeath,Death.NpcDeath, "ShengSiBu");
end

function Death:OnLeave()
GameMain:GetMod('_Event'):UnRegisterEvent(CS.XiaWorld.g_emEvent.NpcDeath,Death.NpcDeath);
end


function Death.NpcDeath(event,npc)
	if CS.GameMain.Instance.FightMap == false then
	local deathble = Death:GetDeathTable(npc)
	local lenth  = #shengsibu;
	--print(deathble[1],deathble[2],deathble[3],deathble[4],deathble[5],deathble[6],deathble[7],deathble[8])
	for i = 1 , 8 , 1 do
	shengsibu[lenth][i] = deathble[i]
	end
	shengsibu[lenth + 1] = {"轮回剩余时间","姓","名","种族","性别","境界","称号","死因"}
	end
end

function Death:OnSave()
	local tbSave = {["Index3"] = shengsibu };
	return tbSave;
end

function Death:OnLoad(tbLoad)
	if tbLoad ~= nil then
		shengsibu = tbLoad["Index3"];
	end
end

function Death:OnStep(dt)
	temptime = temptime + dt;
	if temptime >= 600 then
	temptime = 0;
	if shengsibu ~= nil then
		for k,v in ipairs(shengsibu) do
			if shengsibu[k][1] == 0 then
			Death:TouTai(k);
			else
			shengsibu[k][1] =shengsibu[k][1] - 1;
			end
		end
	end
	end
end

function Death:CheckDeath()
local lenth = #shengsibu
if lenth == 1 then
me:AddMsg("地府目前没有正在进行轮回转世的角色。")
else
for i=1,#shengsibu - 1,1 do
me:AddMsg("姓名："..shengsibu[i][2]..shengsibu[i][3].."   种族："..shengsibu[i][4].."   轮回剩余时间："..shengsibu[i][1].."天\n死因："..shengsibu[i][8].."")
end
end
end

function Death:TouTai(number)
local BornTable = shengsibu[number];
local Name = BornTable[2]..BornTable[3];
local Race = BornTable[4];
local jingjie = BornTable[6];
local random = math.random(0,100);
local tiandao = math.random(1,5);
local flag = 0;
local place = nil;
local RenPlace = {"南屏村","芦墟村","五华村","合欢岛","江岸沃野","中原","河阴城","观海城","盘蛇寨","丰城","大凉城","鸣沙村","寒山镇","落霞镇","稻香村"}
local ShouPlace = {"铜陵山","小凉山","月轮山","平顶山","炼丹峰","云台山","卢山","桂山","雪风原","天螺峪","虫谷","丹霞山","昆仑山","天极峰","九华山","龙虎山","蜀山","五莲山","百蛮山","陷空山","黑山","合欢岛","南海","东海","北海","南荒","大雪原"}
local toutaivalue = nil;
if Race == "【妖兽】" then
toutaivalue = 10;
elseif Race == "【动物】" then
toutaivalue = 5;
elseif Race == "【神兽】" then
toutaivalue = 15;
else
toutaivalue = 20;
end

if jingjie == CS.XiaWorld.g_emGongStageLevel.God2 then
toutaivalue = toutaivalue + 70;
elseif jingjie == CS.XiaWorld.g_emGongStageLevel.God then
toutaivalue = toutaivalue + 30;
elseif jingjie == CS.XiaWorld.g_emGongStageLevel.Dan2 then
toutaivalue = toutaivalue + 15;
elseif jingjie == CS.XiaWorld.g_emGongStageLevel.Dan1 then
toutaivalue = toutaivalue + 10;
elseif jingjie == CS.XiaWorld.g_emGongStageLevel.Qi then
toutaivalue = toutaivalue + 5;
elseif jingjie == CS.XiaWorld.g_emGongStageLevel.None then
toutaivalue = toutaivalue;
else
end
if BornTable[1] ~= "轮回剩余时间" then
if random <= toutaivalue then
for k,v in ipairs(shengercao) do
	if v[4][1] == "五胞胎" then
		for i=1,5,1 do
			if v[4][i + 1][1] == "Index" and flag ~= 1 then
				flag = 1;
				v[4][ i + 1][1] = number;
				v[4][ i + 1][2] = BornTable[2];
				v[4][ i + 1][3] = BornTable[3];
				v[4][ i + 1][4] = BornTable[4];
				v[4][ i + 1][5] = BornTable[5];
				v[4][ i + 1][6] = BornTable[6];
				v[4][ i + 1][7] = BornTable[7];
			end
		end 
	elseif v[4][1] == "四胞胎" then
		for i=1,4,1 do
			if v[4][i + 1][1] == "Index" and flag ~= 1 then
				flag = 1;
				v[4][ i + 1][1] = number;
				v[4][ i + 1][2] = BornTable[2];
				v[4][ i + 1][3] = BornTable[3];
				v[4][ i + 1][4] = BornTable[4];
				v[4][ i + 1][5] = BornTable[5];
				v[4][ i + 1][6] = BornTable[6];
				v[4][ i + 1][7] = BornTable[7];
			end
		end 
	elseif v[4][1] == "三胞胎" then
		for i=1,3,1 do
			if v[4][i + 1][1] == "Index" and flag ~= 1 then
				flag = 1;
				v[4][ i + 1][1] = number;
				v[4][ i + 1][2] = BornTable[2];
				v[4][ i + 1][3] = BornTable[3];
				v[4][ i + 1][4] = BornTable[4];
				v[4][ i + 1][5] = BornTable[5];
				v[4][ i + 1][6] = BornTable[6];
				v[4][ i + 1][7] = BornTable[7];
			end
		end 
	elseif v[4][1] == "二胞胎" then
		for i=1,2,1 do
			if v[4][i + 1][1] == "Index" and flag ~= 1 then
				flag = 1;
				v[4][ i + 1][1] = number;
				v[4][ i + 1][2] = BornTable[2];
				v[4][ i + 1][3] = BornTable[3];
				v[4][ i + 1][4] = BornTable[4];
				v[4][ i + 1][5] = BornTable[5];
				v[4][ i + 1][6] = BornTable[6];
				v[4][ i + 1][7] = BornTable[7];
			end
		end
	elseif v[4][1] == "单胞胎" then
			if v[4][i + 1][1] == "Index" then
				v[4][ i + 1][1] = number;
				v[4][ i + 1][2] = BornTable[2];
				v[4][ i + 1][3] = BornTable[3];
				v[4][ i + 1][4] = BornTable[4];
				v[4][ i + 1][5] = BornTable[5];
				v[4][ i + 1][6] = BornTable[6];
				v[4][ i + 1][7] = BornTable[7];
			end
	else
	end
end
else

local randommath = math.random(0,100)
if tiandao == 1 then
if randommath >= 70 then
local dongwu = {"Lushu","Fei","Rabbit","Wolf","Snake","Boar","Bear","Frog","Turtle"}
local npc = CS.XiaWorld.NpcRandomMechine.RandomNpc(dongwu[math.random(1,#dongwu)]);
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(188, -1, "传闻["..Name.."]在地府修满时间后在【"..Sheng:GetMenPai().."】处重新投胎化为一只刚出生的小动物。", 0, 0, nil, "地府传闻", -1);
CS.XiaWorld.NpcMgr.Instance:AddNpc(npc,CS.XiaWorld.World.Instance.map:RandomBronGrid(),Map,CS.XiaWorld.Fight.g_emFightCamp.None);
npc.PropertyMgr.RelationData:AddOrEditorNameCacheData(BornTable[5], "Reincarnation", BornTable[2], BornTable[3], 0, 0, false, false);
npc.SpecailDesc = Name.."在地府之中修满时间之后重新投胎于【"..Sheng:GetMenPai().."】之中，化为该门派的一只小动物，想必这就是缘分。"
else
place = ShouPlace[math.random(1,#ShouPlace)]
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(188, -1, "传闻["..Name.."]在地府修满时间后在【"..place.."】处重新投胎化为一只刚出生的小动物。", 0, 0, nil, "地府传闻", -1);
end
elseif tiandao == 2 then
--if randommath >= 90 then
--CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(188, -1, "传闻["..Name.."]在地府修满时间后在【"..Sheng:GetMenPai().."】处重新投胎化为一只刚出生的小妖兽。", 0, 0, nil, "地府传闻", -1);

--else
place = ShouPlace[math.random(1,#ShouPlace)]
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(188, -1, "传闻["..Name.."]在地府修满时间后在【"..place.."】处重新投胎化为一只刚出生的小妖兽。", 0, 0, nil, "地府传闻", -1);
--end
else
place = RenPlace[math.random(1,#RenPlace)]
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(188, -1, "传闻["..Name.."]在地府修满时间后在【"..place.."】处重新投胎化为一户人家新生的婴儿。", 0, 0, nil, "地府传闻", -1);
end
table.remove(shengsibu,number)
end
end

end




function Death:GetDeathTime()
local g_emSeason = CS.XiaWorld.g_emSeason
local cake = nil;
local year = World.YearCount + 246;
local season = nil;
local day = World.YearDayCount % 28 + 1
if World.Weather:GetSeason() == g_emSeason.Spring then
season = "春季"
elseif World.Weather:GetSeason() == g_emSeason.Summer then
season = "夏季"
elseif World.Weather:GetSeason() == g_emSeason.Autumn then
season = "秋季"
else
season = "冬季"
end
cake = "天苍"..year.."年"..season.."第"..day.."日"
return cake;
end

--GameMain:GetMod("Lua_Death"):GetDeathTable(world:GetSelectThing())
function Death:GetDeathTable(npc)
local time = Death:GetDeathTime()
local reason = nil;
local JingJie = nil;
local TianQian = nil;
local cycleday = nil;
local laday = nil;
local Race = nil;
local Sex = npc.Sex;
local PreName = npc.PropertyMgr.PrefixName
local SufName = npc.PropertyMgr.SuffixName
local title = nil;
local jingjie = nil;

if npc:GetCurTitle() ~= nil then
title =  "["..npc:GetCurTitle().title.."]";
else
title = "";
end

if npc.DieCause ~= nil then
reason = npc.DieCause;
else
reason = "";
end

if npc.Race.RaceType == CS.XiaWorld.g_emNpcRaceType.Monster then
Race = "【妖兽】"..npc.Race.DisplayName
if npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God2 then
jingjie = CS.XiaWorld.g_emGongStageLevel.God2
JingJie = "[十二境]"
cycleday = 35;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God then
jingjie = CS.XiaWorld.g_emGongStageLevel.God
JingJie = "[九境]"
cycleday = 50;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Dan2 then
jingjie = CS.XiaWorld.g_emGongStageLevel.Dan2
JingJie = "[六境]"
cycleday = 70;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Dan1 then
jingjie = CS.XiaWorld.g_emGongStageLevel.Dan1
JingJie = "[三境]"
cycleday = 95;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Qi then
jingjie = CS.XiaWorld.g_emGongStageLevel.Qi
JingJie = "[一境]"
cycleday = 100;
else
jingjie = CS.XiaWorld.g_emGongStageLevel.None
PreName = npc.Name;
JingJie = "[凡兽]"
cycleday = 124;
end
elseif npc.Race.RaceType == CS.XiaWorld.g_emNpcRaceType.Animal then
jingjie = CS.XiaWorld.g_emGongStageLevel.None
PreName = npc.Name;
Race = "【动物】"
JingJie = "无修为"
cycleday = 20;
elseif npc.Race.RaceType == CS.XiaWorld.g_emNpcRaceType.Boss then
jingjie = CS.XiaWorld.g_emGongStageLevel.God2
Race = "【神兽】"
JingJie = npc.Name
cycleday = 124;
elseif npc.Race.RaceType == CS.XiaWorld.g_emNpcRaceType.Wisdom then
Race = "【人族】"
if npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God2 then
jingjie = CS.XiaWorld.g_emGongStageLevel.God2
JingJie = "[在世真仙]修士"
cycleday = 35;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God then
jingjie = CS.XiaWorld.g_emGongStageLevel.God
JingJie = "[元神期]修士"
cycleday = 50;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Dan2 then
jingjie = CS.XiaWorld.g_emGongStageLevel.Dan2
JingJie = "[金丹期]修士"
cycleday = 70;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Dan1 then
jingjie = CS.XiaWorld.g_emGongStageLevel.Dan1
JingJie = "[结丹期]修士"
cycleday = 95;
elseif npc.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.Qi then
jingjie = CS.XiaWorld.g_emGongStageLevel.Qi
JingJie = "[炼气期]修士"
cycleday = 100;
else
jingjie = CS.XiaWorld.g_emGongStageLevel.None
JingJie = "[凡人]"
cycleday = 124;
end
else
return;
end


if npc.PropertyMgr:GetProperty("GodPenaltyAddV") >= 30 then
TianQian = "罪孽深重"
cycleday = cycleday * 3;
elseif npc.PropertyMgr:GetProperty("GodPenaltyAddV") >= 10 then
TianQian = "略有造孽"
cycleday = cycleday * 2;
elseif npc.PropertyMgr:GetProperty("GodPenaltyAddV") <= -10 then
TianQian = "有积功德"
cycleday = cycleday / 0.5;
elseif npc.PropertyMgr:GetProperty("GodPenaltyAddV") <= -30 then
TianQian = "功德圆满"
cycleday = cycleday / 0.2;
else
TianQian = "遵循因果"
cycleday = cycleday;
end
laday = cycleday - cycleday % 1;


local all = title..npc.Name.."于"..time.."在".."【"..Sheng:GetMenPai().."】死于"..reason.."后进入阴曹地府，因其身份为"..Race..JingJie.."且"..TianQian.."，故需要在地府等待大约"..laday.."日后方可投胎。"
return {cycleday,PreName,SufName,Race,Sex,jingjie,title,all};
end



function Death:PrintTable()
for i = 1, #shengsibu , 1 do
print(shengsibu[i][1],shengsibu[i][2],shengsibu[i][3],shengsibu[i][4],shengsibu[i][5],shengsibu[i][6],shengsibu[i][7],shengsibu[i][8])
end
end

function Sheng:GetMenPai()
local MenPai = nil;
local SchoolP = nil;
local SchoolS = nil;
if CS.GameMain.Instance.FightMap == true then
MenPai = CS.XiaWorld.SchoolGlobleMgr.Instance:GetSchoolName(PlacesMgr:GetPlaceData(CS.XiaWorld.FightMapMgr.MainMap.FromMap).School);
else
if CS.XiaWorld.SchoolMgr.Instance.Prefix == nil then
SchoolP = "";
else
SchoolP = CS.XiaWorld.SchoolMgr.Instance.Prefix;
end
if CS.XiaWorld.SchoolMgr.Instance.Suffix == nil then
SchoolS = "";
else
SchoolS = CS.XiaWorld.SchoolMgr.Instance.Suffix;
end
MenPai = SchoolP..SchoolS;
end
return MenPai;
end

-------------------------------------------------------------------------------------分手

function Sheng:FenShouPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if npc1.Camp == npc2.Camp and npc1.Race.RaceType == npc2.Race.RaceType then
if npc1.PropertyMgr.RelationData:IsRelationShipWith("Lover",npc2) then
return true;
else
return false;
end
end
return false;
end

function Sheng:FenShou()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
npc1.PropertyMgr.RelationData:RemoveRelationShip(npc2,"Lover");
me:AddMsg(""..npc1.Name.."和"..npc2.Name.."说：“我们不适合，分手吧！”，只见"..npc2.Name.."无论如何劝阻，都阻止不了"..npc1.Name.."的决定，两人和平分手。");
npc2:AddMemery(""..npc1.Name.."和我不合适，也许他能找到更好的人，祝他以后幸福...");
npc1:AddMemery(""..npc2.Name.."为什么要和我分手，是我哪里做的不对吗？？？");
end


-------------------------------------------------------------------------------------求婚

function Sheng:QiuHunPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if npc1.Camp == npc2.Camp and npc1.Race.RaceType == npc2.Race.RaceType then
if npc1.PropertyMgr.RelationData:IsRelationShipWith("Spouse",npc2) == false and npc1.PropertyMgr.RelationData:IsRelationShipWith("Lover",npc2) then
return true;
else
return false;
end
end
return false;
end

function Sheng:QiuHun()
world:SetRandomSeed();
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local relation1 = npc1.PropertyMgr.RelationData:GetRelationData(npc2).Value
local relation2 = npc2.PropertyMgr.RelationData:GetRelationData(npc1).Value
local random = npc1.LuaHelper:RandomInt(0,10)
if relation1 >= 90 and relation2 >= 90 and random > 4 then
Sheng:MerryEvent();
me:AddMsg(""..npc1.Name.."接受了"..npc2.Name.."的求婚，他们成为了夫妻！");
else
me:AddMsg(""..npc1.Name.."拒绝了"..npc2.Name.."的求婚，并和"..npc2.Name.."说：“我还想再想想！”");
end
end


function Sheng:MerryEvent()
	local nan = nil;
	local nv = nil;
	local nanID = nil;
	local nvID = nil;
	local number = nil;
	local id1 = me.npcObj.ID;
	local id2 = story:GetBindThing().ID;
	if me.npcObj.Sex == CS.XiaWorld.g_emNpcSex.Male then
	nan = ThingMgr:FindThingByID(id1)
	nv = ThingMgr:FindThingByID(id2)
	nanID = id1;
	nvID = id2;
	else
	nan = ThingMgr:FindThingByID(id2)
	nv = ThingMgr:FindThingByID(id1)
	nanID = id2;
	nvID = id1;
	end
	number = Sheng:allnumber(nanID,nvID)
	nan:AddMood("SiShou");
	nv:AddMood("SiShou");
	world:PlayBGM("Spr/merry.ogg",false);
	if number >= 25 then
	World.Weather:BeginWeather("LightningStorm", true, 0, true);
	CS.XiaWorld.ThingMgr.Instance:AddItemThing(nv.Key,"Item_Dan_LongDan1",Map)
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的一对道侣选择了一个良辰吉日结婚，这对新人真是天作之合，竟然引得一条神龙路过围观，同时神龙还留下一份礼物给新人，消息传到门派之外后，其余门派羡慕不已。", 0, 0, nil, "喜结良缘", -1);
	world:ShowMsgBox("大吉之日，凑齐天时地利人和！该地的气息如此喜庆，引来了一条神龙参观！","神兽经过")
	elseif number >= 10 then
	Sheng:ShiZheZhuHe()
	world:ShowMsgBox("吉祥之日，这场婚姻必定美满！周围关系好的门派都派来了使者前来送礼祝贺！","使者祝贺")
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的一对道侣选择了一个美满之日结婚，门派内喜庆连连，周围关系好的门派也都派来了使者和礼物给这对新人进行祝福。", 0, 0, nil, "喜结良缘", -1);
	elseif number <= -40 then
	World.Weather:BeginWeather("LightningStormNoLong", true, 0, true);
	Sheng:ZhenXianDiRen()
	world:ShowMsgBox("大凶之日，竟然有人在这个日子结婚！碰巧一个大魔头路过，要进行搅局！","敌人进攻")
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的一对道侣选择了一个大凶之日结婚，碰巧一个合欢派大魔头路过此地，见新娘如此貌美，竟想掠劫新娘作为自己修炼的炉鼎，整个门派不得不为修仙界除害。", 0, 0, nil, "喜结良缘", -1);
	elseif number <= -20 then
	Sheng:ShouChao()
	world:ShowMsgBox("时日不佳，竟然有人在这个日子结婚！兽神靡下的兽群碰巧路过！","兽群进攻")
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的一对道侣选择了一个时日不佳的日子结婚，引得兽神靡下的兽群前来攻击，消息传到其余门派后，周围的门派都不太看好这一对新人。", 0, 0, nil, "喜结良缘", -1);
	else
	world:ShowMsgBox("祝两位新人在未来的日子里同甘共苦！","新婚快乐")
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的一对道侣选择了一个不错的日子结婚，门派内欢声笑语，师兄弟们接连送上祝福，消息传到其余门派后，门派也默默祝福这一对新人。", 0, 0, nil, "喜结良缘", -1);
	end
	Sheng:MerryMood(nanID,nvID)
	nv:AddSimpleActionCommand(6,"ksXL","祝贺")
	nan:AddSimpleActionCommand(6,"ksXL","祝贺")
	nan.PropertyMgr.RelationData:AddRelationShip(nv,"Spouse");
	nan.PropertyMgr.RelationData:RemoveRelationShip(nv,"Lover");
	nan.PropertyMgr:AddModifier("NewMan");
	nv.PropertyMgr:AddModifier("NewWoMan");
end


function Sheng:MerryMood(nanID,nvID)
local Count = ThingMgr.NpcList.Count
local npc1 = ThingMgr:FindThingByID(nanID)
local npc2 = ThingMgr:FindThingByID(nvID)
local name1 = npc1.Name;
local name2 = npc2.Name;
for i = 0,Count-1,1 do
if ThingMgr.NpcList[i].Camp == CS.XiaWorld.Fight.g_emFightCamp.Player then
local npc = ThingMgr.NpcList[i]
npc:AddMood("ZhuHe");
npc:AddMemery(""..name1.."和"..name2.."的婚礼好隆重，我好喜欢！");
end
end
end



function Sheng:ZhenXianDiRen()
npc = CS.XiaWorld.NpcRandomMechine.RandomNpc("Human");
CS.XiaWorld.NpcMgr.Instance:AddNpc(npc,550,Map,CS.XiaWorld.Fight.g_emFightCamp.Enemy);
CS.XiaWorld.ThingMgr.Instance:EquptNpc(npc,12,CS.XiaWorld.g_emNpcRichLable.Richest);
npc.PropertyMgr.Practice:ChangeGong("Gong_3_Jin");
npc.PropertyMgr.Practice.GodCount = 1
while(npc.LuaHelper:GetGLevel() ~= 12)
do
npc.PropertyMgr.Practice:AddPractice(9999999)
npc.PropertyMgr.Practice:BrokenNeck();
if npc.LuaHelper:GetGLevel() == 12 then
while(npc.PropertyMgr.Practice.StageValue ~= npc.PropertyMgr.Practice.CurStage.Value)
do
npc.PropertyMgr.Practice:AddPractice(20000000)
npc.PropertyMgr.Practice:BrokenNeck();
end
end
end
npc.PropertyMgr.Practice:MakeGold(1000000);
npc.PropertyMgr.Practice:RandomTree();
npc:AddLing(9999999);
npc.FightBody.AutoNext = true;
npc.FightBody.IsAttacker = true;
npc.FightBody.AttackWait = 20;
npc.FightBody.AttackTime = 100;
npc.EnemyType = CS.XiaWorld.Fight.g_emEnemyType.Attacker;
npc:AddTitle("合欢派魔头");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_BasePropertie")
npc.PropertyMgr:AddModifier("Modifier_SpNpc_BaseFightPropertie");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_Ling");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_Shield");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_FabaoAtk");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_FabaoSpeed");
npc.PropertyMgr:AddModifier("Modifier_SpNpc_FabaoDisp");
end

function Sheng:ShouChao()
	for i=1,15,1 do
	local bear = CS.XiaWorld.NpcRandomMechine.RandomNpc("Bear");	
	CS.XiaWorld.NpcMgr.Instance:AddNpc(bear,550+i,Map,CS.XiaWorld.Fight.g_emFightCamp.Enemy);
	bear.FightBody.TargetID = id1;
	bear.FightBody.AutoNext = true;
	bear.FightBody.IsAttacker = true;
	bear.FightBody.AttackWait = 20;
	bear.FightBody.AttackTime = 100;
	bear.EnemyType = CS.XiaWorld.Fight.g_emEnemyType.Attacker;
	local name = bear:GetName();
	bear:SetName("兽之"..name.."");
	end
end

function Sheng:ShiZheZhuHe()
local value = nil;
school = {[1]="丹霞洞天",[2]="昆仑宫",[3]="极天宫",[4]="紫霄宗",[5]="正一道",[6]="青莲剑宗",[7]="栖霞洞天",[8]="百蛮山",[9]="七仟坞",[10]="七杀魔宫",[11]="合欢派",[12]="万妖殿"}
item = {[1]="Item_TuEssence",[2]="Item_Dan_TreeEXP",[3]="Item_Dan_LingYuanZhong",[4]="Item_Dan_IncreaseLife5",[5]="Item_JinEssence",[6]="Item_HuoEssence",[7]="Item_ShuiEssence",[8]="Item_SoulPearl",[9]="Item_MuEssence",[10]="Item_ThunderAir",[11]="Item_Shit",[12]="Item_StarEssenceBlock"}
for i=1,12,1 do
value = me:GetSchoolRelation(i)
if value >= 800 then
npc = CS.XiaWorld.NpcRandomMechine.RandomNpc("Human");
CS.XiaWorld.NpcMgr.Instance:AddNpc(npc,400+5*i,Map,CS.XiaWorld.Fight.g_emFightCamp.Friend);
CS.XiaWorld.ThingMgr.Instance:AddItemThing(400+5*i,""..item[i].."",Map);
CS.XiaWorld.ThingMgr.Instance:EquptNpc(npc,12,CS.XiaWorld.g_emNpcRichLable.Richest);
npc.PropertyMgr:AddModifier("SysVistorModifier");
npc.PropertyMgr:FindModifier("SysVistorModifier").Duration = 1200;
npc:ChangeRank(CS.XiaWorld.g_emNpcRank.Normal,true,true,true);
npc:AddTitle(""..school[i].."使者");
npc.JobEngine:ClearBehaviour()
npc:InitBehaviour()
end
end
end

-----------------------------------------------------------------------------驯兽
function Sheng:XunShouPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if (npc1.IsEliteEnemy and npc2.IsDisciple and npc1.Camp ~= npc2.Camp) or (npc1.IsPassiveAttacker and npc2.IsDisciple and npc1.Camp ~= npc2.Camp) then
return true;
else
return false;
end
end

function Sheng:XunShou()
world:SetRandomSeed();
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local number1 = npc1.LuaHelper:GetGLevel()
local number2 = npc2.LuaHelper:GetGLevel()
local random = me:RandomInt(0,100)
if npc1.IsPassiveAttacker then
if random < number2 + 30 then
npc1:ChangeRank(CS.XiaWorld.g_emNpcRank.Normal)
npc1:SetCamp(CS.XiaWorld.Fight.g_emFightCamp.Player)
me:AddMsg(""..npc2.Name.."成功驯服了"..npc1.Name.."。")
else
me:AddMsg(""..npc2.Name.."驯服"..npc1.Name.."失败。")
end
else
if number2 >= number1 then
if random < (number2 - number1 + 15) * 2 then
me:AddMsg(""..npc2.Name.."成功驯服了"..npc1.Name.."，门派战斗力更上一层楼。")
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】中的内门长老【"..npc2.Name.."】成功驯服了妖兽【"..npc1.Name.."】，门派实力更上一层楼。", 0, 0, nil, "喜结良缘", -1);
Sheng:AddYaoShouID(npc1.ID)
npc1:ChangeRank(CS.XiaWorld.g_emNpcRank.Normal)
npc1:SetCamp(CS.XiaWorld.Fight.g_emFightCamp.Player)
npc1.JobEngine:ClearJob()
npc1.JobEngine:ClearBehaviour()
npc1:InitBehaviour()
else
me:AddMsg(""..npc2.Name.."驯服"..npc1.Name.."失败。")
end
else
me:AddMsg(""..npc2.Name.."境界不足以驯服"..npc1.Name.."。")
end
end
end

function Sheng:AddYaoShouID(id)
table.insert(YaoShouID,id);
end

function Sheng:RemoveYaoShouID(index0)
table.remove(YaoShouID,index0)
end

function Sheng:GetYaoShouID()
return YaoShouID;
end

function YaoShou:OnModeEnter(p)
	self:SetKeyCondition("Npc")
	self:OpenThingCheck()
	self:ShowLine(p[1])
	self:SetHeadMsg("请选择一个敌方NPC")
end

function YaoShou:CheckThing(key)
	local npc = self:GetMap().Things:GetThingAtGrid(key, g_emThingType.Npc)
	if npc.Camp ~= CS.XiaWorld.Fight.g_emFightCamp.Player then
	return true;
	else
	return false;
	end
end

function YaoShou:Apply(key)
	local map = self:GetMap()
	local target = map.Things:GetThingAtGrid(key, g_emThingType.Npc)
	local ID = target.ID
	local YaoShouID = GameMain:GetMod("Lua_Sheng"):GetYaoShouID()
	for i = 1,#YaoShouID,1 do
		local npc = ThingMgr:FindThingByID(YaoShouID[i])
		if npc ~= nil then
			npc.JobEngine:ClearJob()
			npc:FightWith(target,true)
		end
	end
end

-----------------------------------------------------------------------------表白

function Sheng:BiaoBaiPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if npc1.Camp == npc2.Camp and npc1.Race.RaceType == npc2.Race.RaceType then
if npc1.PropertyMgr.RelationData:IsRelationShipWith("Lover",npc2) or npc1.PropertyMgr.RelationData:IsRelationShipWith("Spouse",npc2) then
return false;
else
return true;
end
end
return false;
end

function Sheng:BiaoBai()
world:SetRandomSeed()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local relation1 = npc1.PropertyMgr.RelationData:GetRelationData(npc2).Value
local relation2 = npc2.PropertyMgr.RelationData:GetRelationData(npc1).Value
local random = npc1.LuaHelper:RandomInt(0,10)
if relation1 >= 70 and relation2 >= 70 and random >= 4 then
npc2.PropertyMgr.RelationData:AddRelationShip(npc1,"Lover");
npc2.PropertyMgr.RelationData:RemoveRelationShip(npc1,"Fancy")
npc1.PropertyMgr.RelationData:RemoveRelationShip(npc2,"Fancy")
me:AddMsg(""..npc1.Name.."接受了"..npc2.Name.."的表白，他们成为了恋人！");
world:PlayBGM("Spr/lover.ogg",false);
else
npc2.PropertyMgr.RelationData:AddRelationShip(npc1,"Fancy");
me:AddMsg(""..npc1.Name.."并没有接受"..npc2.Name.."的表白，并和"..npc2.Name.."说：“你是个好人！”");
end
end

---------------------------------------------------------------------结拜

function Sheng:JieBaiPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID);
npc2 = ThingMgr:FindThingByID(me.npcObj.ID);
if npc1.Camp == npc2.Camp and npc1.Race.RaceType == npc2.Race.RaceType and npc1.Sex == npc2.Sex then
if npc1.PropertyMgr.RelationData:IsRelationShipWith("Friend",npc2) then
return false;
else
return true;
end
end
return false;
end

function Sheng:JieBai()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local relation1 = npc1.PropertyMgr.RelationData:GetRelationData(npc2).Value
local relation2 = npc2.PropertyMgr.RelationData:GetRelationData(npc1).Value
if relation1 >= 40 and relation2 >= 40 then
npc1.PropertyMgr.RelationData:AddRelationShip(npc2,"Friend");
me:AddMsg(""..npc1.Name.."爽快得答应了"..npc2.Name.."的结拜邀请，就在此时此刻"..npc1.Name.."与"..npc2.Name.."不求同年同月同日生，但求同年同月死！在此立下天道之誓！")
else
me:AddMsg(""..npc1.Name.."并没有答应"..npc2.Name.."的结拜请求，并觉得"..npc2.Name.."太随便了...");
end
end

-----------------------------------------------------------------------------------行房

function Sheng:PaPaPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if npc1.Camp == npc2.Camp and npc1.Race.RaceType == npc2.Race.RaceType then
if npc1.PropertyMgr.RelationData:IsRelationShipWith("Spouse",npc2) then
return true;
else
return false;
end
end
return false;
end

function Sheng:JiaoPeiPD()
	local nan = nil;
	local nv = nil;
	local id1 = me.npcObj.ID;
	local id2 = story:GetBindThing().ID;
	if me.npcObj.Sex ==CS.XiaWorld.g_emNpcSex.Male then
	nan = ThingMgr:FindThingByID(id1)
	nv = ThingMgr:FindThingByID(id2)
	else
	nan = ThingMgr:FindThingByID(id2)
	nv = ThingMgr:FindThingByID(id1)
	end
	if nan.Age >= 18 and nv.Age >= 18 then
	if nv.PropertyMgr:CheckFeature("YunFu") == false then
	if nan.PropertyMgr.BodyData:PartIsBroken("Genitals") == false then
	Sheng:JiaoPei()
	else
	me:AddMsg("大哥...没有那根东西你怎么玩呀？");
	end
	else
	me:AddMsg("她都已经怀孕了，还这样？？？")
	end
	else
	me:AddMsg("双方有未成年，你是禽兽吗？")
	end
end

function Sheng:JiaoPei()
world:SetRandomSeed()
npc1 = story:GetBindThing();
npc2 = me.npcObj;
local nan = nil;
local nv = nil;
local value1 = 24;
local value2 = 24;
if npc1.Sex == CS.XiaWorld.g_emNpcSex.Male then
nan = npc1;
nv = npc2;
else
nan = npc2;
nv = npc1;
end
if npc1.Disciple == true then
value1 = npc1.LuaHelper:GetGLevel() * 2 + 24
end
if npc2.Disciple == true then
value2 = npc2.LuaHelper:GetGLevel() * 2 + 24
end
local random = npc1.LuaHelper:RandomInt(0,100)
if nan.Sex == nv.Sex then
	nan:AddMood("ShuFu");
	nv:AddMood("ShuFu");
	me:AddMsg("少儿不宜场面进行中...");
	me:AddMsg("两位虽然性别相同，但的确是真爱，他们享受了精神肉体上的愉悦。");
else
if nan.LuaHelper:CheckItemEquptCount("Item_BYT") == true then
	nan:AddMood("TaoKong");
	nv:AddMood("ShuFu");
	me:AddMsg("少儿不宜场面进行中...");
	me:AddMsg("双方都身心愉快！");
elseif random >= (value1 + value2) then
	nan:AddMood("TaoKong");
	nv:AddMood("ShuFu");
	me:AddMsg("少儿不宜场面进行中...");
	me:AddMsg("双方都身心愉快！");
	Sheng:huaiyun();
else
	nan:AddMood("TaoKong");
	nv:AddMood("ShuFu");
	me:AddMsg("少儿不宜场面进行中...");
	me:AddMsg("双方都身心愉快！");
end
end
end

function Sheng:huaiyun()
	world:SetRandomSeed();
	local npc1 = story:GetBindThing();
	local npc2 = me.npcObj;
	local lenth = #shengercao;
	local random = npc1.LuaHelper:RandomInt(0,100)
	if npc2.Sex == CS.XiaWorld.g_emNpcSex.Female then
		local MotherName = npc2.Name
		local FatherName = npc1.Name
		shengercao[lenth][1] = story:GetBindThing().ID;
		shengercao[lenth][2] = npc2.ID;
	else
		local MotherName = npc1.Name
		local FatherName = npc2.Name
		shengercao[lenth][1] = npc2.ID;
		shengercao[lenth][2] = story:GetBindThing().ID;
	end
		shengercao[lenth][3] = 0;
	local father = ThingMgr:FindThingByID(shengercao[lenth][1])
	local mother = ThingMgr:FindThingByID(shengercao[lenth][2])
	local Fname = father.Name;
	local Mname = mother.Name;

		if random >= 99 then
			shengercao[lenth][4] = {"五胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}};
		elseif random >= 95 then
			shengercao[lenth][4] = {"四胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}};
		elseif random >= 88 then
			shengercao[lenth][4] = {"三胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}};
		elseif random >= 75 then
			shengercao[lenth][4] = {"双胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"},{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}};
		else
			shengercao[lenth][4] = {"单胞胎",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}};
		end
		shengercao[lenth+1] = {0,0,"未生产",{"未知",{"Index","Prename","Sufname","Race","Sex","JingJie","Title"}}}
			CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】中的弟子【"..mother.Name.."】与【"..father.Name.."】在行房之时操作不慎，致使【"..mother.Name.."】怀上了【"..father.Name.."】的骨肉，门派内各人喜庆连连，消息同时也传到了门派之外。", 0, 0, nil, "喜结良缘", -1);
			me:AddMsg("恭喜"..Fname.."和"..Mname.."，"..Mname.."成功怀孕！等待小宝宝的诞生吧！");
			mother.PropertyMgr:AddFeature("YunFu");
			father:AddMood("BaBa");
			father:AddMemery(""..Fname.."非常地高兴，因为他即将成为父亲！");
			mother:AddMemery(""..Mname.."非常地高兴，因为她即将成为母亲！");
end

-------------------------------------------------------------------------------------------

function Sheng:shenger(n)
world:SetRandomSeed();
local mother = ThingMgr:FindThingByID(shengercao[n][2])
local father = ThingMgr:FindThingByID(shengercao[n][1])
local temp = nil;
mother:AddSimpleActionCommand(6,"ksXL","祝贺")
if shengercao[n][4][1] == "五胞胎" then
zhensheng(n,5)
temp = "五个"
elseif shengercao[n][4][1] == "四胞胎" then
zhensheng(n,4)
temp = "四个"
elseif shengercao[n][4][1] == "三胞胎" then
zhensheng(n,3)
temp = "三个"
elseif shengercao[n][4][1] == "双胞胎" then
zhensheng(n,2)
temp = "二个"
else
zhensheng(n,1)
temp = "一个"
end
father:AddMemery(""..father.Name.."喜当"..temp.."孩子爹！他非常高兴！");
father:AddMood("DanSheng")
mother:AddMemery(""..mother.Name.."生下"..temp.."哪吒...她感觉十分诧异！");
mother:AddMood("DanSheng")
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】中的【"..mother.Name.."】成功分娩出了【"..shengercao[n][4][1].."】，门派再添新丁，相信新生代将会很快的成长，将来这个门派实力必然快速提升，修仙界地位水涨船高。", 0, 0, nil, "喜结良缘", -1);
world:ShowMsgBox("[color=#D06508]恭喜恭喜，"..mother.Name.."生下了"..shengercao[n][4][1].."，门派再添新丁。[/color]","【婴儿诞生】")
end

function zhensheng(n,q)
for i = 1 , q ,1 do
local npc = CS.XiaWorld.NpcRandomMechine.RandomNpc("Human");	

local mother = nil;
local father = nil;
local PreName = nil;

local sex = nil;

if ThingMgr:FindThingByID(shengercao[n][2]) ~= nil then
mother = ThingMgr:FindThingByID(shengercao[n][2])
else
return;
end

if ThingMgr:FindThingByID(shengercao[n][1]) ~= nil then
father = ThingMgr:FindThingByID(shengercao[n][1]);
else
father = ThingMgr:FindThingByID(shengercao[n][2]);
end

PreName = father.PropertyMgr.PrefixName

mother.PropertyMgr:RemoveFeature("YunFu");
local FatherFeature = father.PropertyMgr.FeatureList[npc.LuaHelper:RandomInt(0,father.PropertyMgr.FeatureList.Count-1)].Name
local MotherFeature = mother.PropertyMgr.FeatureList[npc.LuaHelper:RandomInt(0,mother.PropertyMgr.FeatureList.Count-1)].Name
CS.XiaWorld.NpcMgr.Instance:AddNpc(npc,mother.Key,Map,CS.XiaWorld.Fight.g_emFightCamp.Player);
npc.PropertyMgr.RelationData:AddRelationShip(mother, "Parent");
npc.PropertyMgr.RelationData:AddRelationShip(father, "Parent");
npc.PropertyMgr.Age = 1;
npc:ChangeRank(CS.XiaWorld.g_emNpcRank.Worker);
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Charisma,(mother.LuaHelper:GetCharisma() + father.LuaHelper:GetCharisma())/2 - npc.PropertyMgr.Charisma +npc.LuaHelper:RandomInt(-2,2));
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Luck,(mother.LuaHelper:GetLuck() + father.LuaHelper:GetLuck())/2- npc.PropertyMgr.Luck +npc.LuaHelper:RandomInt(-2,2));
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Intelligence,(mother.LuaHelper:GetIntelligence() + father.LuaHelper:GetIntelligence())/2- npc.PropertyMgr.Intelligence +npc.LuaHelper:RandomInt(-2,2));
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Perception,(mother.LuaHelper:GetPerception() + father.LuaHelper:GetPerception())/2- npc.PropertyMgr.Perception +npc.LuaHelper:RandomInt(-2,2));
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Physique,(mother.LuaHelper:GetPhysique() + father.LuaHelper:GetPhysique())/2- npc.PropertyMgr.Physique +npc.LuaHelper:RandomInt(-2,2));
npc.PropertyMgr:AddFeature(MotherFeature);
npc.PropertyMgr:AddFeature(FatherFeature);
npc.PropertyMgr:AddFeature("YingEr");
npc:AddModifier("YingErShi")

if npc.Sex == CS.XiaWorld.g_emNpcSex.Female then
npc.PropertyMgr:ChangeName(PreName,NpcMgr:GetRandomSuffixName("Human", CS.XiaWorld.g_emNpcSex.Female))
	npc.HairID = mother.HairID;
	sex = "女孩"
else
npc.PropertyMgr:ChangeName(PreName,NpcMgr:GetRandomSuffixName("Human", CS.XiaWorld.g_emNpcSex.Male))
	npc.HairID = father.HairID;
	sex = "男孩"
end

if shengercao[n][4][i + 1][1] ~= "Index" then

npc.PropertyMgr.RelationData:AddOrEditorNameCacheData(shengercao[n][4][i + 1][5], "Reincarnation",shengercao[n][4][i + 1][2], shengercao[n][4][i + 1][3], 0, 0, false, false);
npc.SpecailDesc = shengercao[n][4][i + 1][4]..shengercao[n][4][i + 1][7]..shengercao[n][4][i + 1][2]..shengercao[n][4][i + 1][3].."在地府之中修满时间后重新投胎转世，恰巧这一世化为"..mother.Name.."和"..father.Name.."的孩子，想必这就是缘分吧。"

if shengercao[n][4][i + 1][6] == CS.XiaWorld.g_emGongStageLevel.God2 then
npc.PropertyMgr:AddModfier("LunHui_God2")
elseif shengercao[n][4][i + 1][6] == CS.XiaWorld.g_emGongStageLevel.God then
npc.PropertyMgr:AddModfier("LunHui_God")
elseif shengercao[n][4][i + 1][6] == CS.XiaWorld.g_emGongStageLevel.Dan2 then
npc.PropertyMgr:AddModfier("LunHui_Dan2")
elseif shengercao[n][4][i + 1][6] == CS.XiaWorld.g_emGongStageLevel.Dan1 then
npc.PropertyMgr:AddModfier("LunHui_Dan1")
elseif shengercao[n][4][i + 1][6] == CS.XiaWorld.g_emGongStageLevel.Qi then
npc.PropertyMgr:AddModfier("LunHui_Qi")
else
end

table.remove(shengsibu,shengercao[n][4][i+1][1])

end

if  npc.view ~= nil then
       npc.view.needUpdateMod = true;
end

local Skill = npc.PropertyMgr.SkillData;
local g_emNpcSkillType = CS.XiaWorld.g_emNpcSkillType;
local YING = npc:GetName()
local ffname = NpcMgr.FeatureMgr:GetDef(FatherFeature).DisplayName;
local mfname = NpcMgr.FeatureMgr:GetDef(MotherFeature).DisplayName;
local FGong = nil;
local MGong = nil;
local FGod = nil;
local MGod = nil;
local modifier = nil;
local Cancel = "不继承";
local FDisplayName = nil;
local MDisplayName = nil;

if father.IsDisciple == true then
if father.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God2 then
npc.PropertyMgr:AddModfier(Sheng:GongElmentM(CS.XiaWorld.PracticeMgr.Instance:GetGongDef(father.LuaHelper:GetGongName()).ElementKind))
end
FDisplayName = CS.XiaWorld.PracticeMgr.Instance:GetGongDef(father.LuaHelper:GetGongName()).DisplayName
FGong = "父系传承【"..FDisplayName.."】"
else
FGong = "父系无传承功法"
end

if mother.IsDisciple == true then
if mother.PropertyMgr.Practice.GongStateLevel == CS.XiaWorld.g_emGongStageLevel.God2 then
npc.PropertyMgr:AddModfier(Sheng:GongElmentM(CS.XiaWorld.PracticeMgr.Instance:GetGongDef(mother.LuaHelper:GetGongName()).ElementKind))
end
MDisplayName = CS.XiaWorld.PracticeMgr.Instance:GetGongDef(mother.LuaHelper:GetGongName()).DisplayName
MGong = "母系继承【"..MDisplayName.."】"
else
MGong = "母系无传承功法"
end

world:ShowStoryBox("[size=14][color=#f0e70f]恭喜！出生的是个"..sex.."！\n该婴儿名为"..YING.."，其属性：\n继承了父亲["..father.Name.."]的【"..ffname.."】特性      \n继承了母亲["..mother.Name.."]的【"..mfname.."】特性[/color][/size][color=#f00f17]\n【神识】"..npc.LuaHelper:GetPerception().."   【根骨】"..npc.LuaHelper:GetPhysique().."    【魅力】"..npc.LuaHelper:GetCharisma().."    【悟性】"..npc.LuaHelper:GetIntelligence().."   【机缘】"..npc.LuaHelper:GetLuck().."\n气感："..Skill:GetSkillLevel(g_emNpcSkillType.Qi).."   战斗："..Skill:GetSkillLevel(g_emNpcSkillType.Fight).."   社交："..Skill:GetSkillLevel(g_emNpcSkillType.SocialContact).."   岐黄："..Skill:GetSkillLevel(g_emNpcSkillType.Medicine).."   \n厨艺："..Skill:GetSkillLevel(g_emNpcSkillType.Cooking).."   筑工："..Skill:GetSkillLevel(g_emNpcSkillType.Building).."   农耕："..Skill:GetSkillLevel(g_emNpcSkillType.Farming).."   采矿："..Skill:GetSkillLevel(g_emNpcSkillType.Mining).."   \n雅艺："..Skill:GetSkillLevel(g_emNpcSkillType.Art).."   巧匠："..Skill:GetSkillLevel(g_emNpcSkillType.Manual).."   斗法："..Skill:GetSkillLevel(g_emNpcSkillType.DouFa).."   丹器："..Skill:GetSkillLevel(g_emNpcSkillType.DanQi).."   [/color]\n是否要继承父母的功法或者遗弃婴儿？","婴儿出生",{FGong,MGong,"抛弃婴儿",Cancel},
function(key)
	if key == 0 then
	if father.IsDisciple == true then
	npc.PropertyMgr.Practice:Up2Disciple(father.LuaHelper:GetGongName())
	return ""..YING.."继承了父亲"..father.Name.."的功法——"..FDisplayName.."！"
	else
	return "父亲不是内门弟子，所以不能传承功法！"
	end
	end
	if key == 1 then
	if mother.IsDisciple == true then
	npc.PropertyMgr.Practice:Up2Disciple(mother.LuaHelper:GetGongName())
	return ""..YING.."继承了母亲"..mother.Name.."的功法——"..MDisplayName.."！"
	else
	return "母亲不是内门弟子，所以不能传承功法！"
	end
	end
	if key == 2 then
	if CS.ModsMgr.Instance:FindMod("4141100caf48411889939ee27fea08f1") ~= nil and GameMain:GetMod("XWebSocket").ws then
	Sheng:MakeMsg(npc.ID,MotherFeature,FatherFeature)
	end
	ThingMgr:RemoveThing(npc);
	CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】的外门在夜黑风高之时鬼鬼祟祟地跑到门派外泥泞小路中扔下一坨不知名的东西，恰巧被路过的月轮山村民所瞧见，【"..Sheng:GetMenPai().."】外门被看到后做贼心虚地回到门派。", 0, 0, nil, "喜结良缘", -1);
	return ""..YING.."因天资愚钝，不符合贵派入门要求而被门派强制勒令遗弃在门派之外的泥泞路段上，生死听天由命。"
	end
	if key == 3 then
	return ""..YING.."并没有继承父母的衣钵（你们好狠心！）。"
	end
end
);
end
end

function Sheng:GongElmentM(STRING)
local modifier = nil;
if STRING == CS.XiaWorld.g_emElementKind.None then
modifier = "WU_GOD";
elseif STRING == CS.XiaWorld.g_emElementKind.Jin then
modifier = "JIN_GOD";
elseif STRING == CS.XiaWorld.g_emElementKind.Mu then
modifier = "MU_GOD";
elseif STRING == CS.XiaWorld.g_emElementKind.Shui then
modifier = "SHUI_GOD";
elseif STRING == CS.XiaWorld.g_emElementKind.Huo then
modifier = "HUO_GOD";
elseif STRING == CS.XiaWorld.g_emElementKind.Tu then
modifier = "TU_GOD";
else
modifier = "WU_GOD";
end
return modifier;
end

--------------------------------------------------------------------------------------------劝说

function Sheng:QuanShuoPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID);
npc2 = ThingMgr:FindThingByID(me.npcObj.ID);
if npc1.Race.RaceType == npc2.Race.RaceType and npc1.Camp ~= npc2.Camp then
return true;
else
return false;
end
end

function Sheng:QuanShuo()
world:SetRandomSeed();
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local name1 = npc1.Name;
local name2 = npc2.Name;
local random = npc1.LuaHelper:RandomInt(0,100)
if  random >= 80 then
if npc1.IsDisciple == true then
npc1:SetCamp(CS.XiaWorld.Fight.g_emFightCamp.Player)
npc1:ChangeRank(CS.XiaWorld.g_emNpcRank.Disciple)
if npc1.PropertyMgr:FindModifier("SysVistorModifier") ~= nil then
npc1.PropertyMgr:RemoveModifier("SysVistorModifier")
end
me:AddMsg(""..name1.."接受了"..name2.."的劝说并决定加入这个坑爹的门派。。。")
else
npc1:SetCamp(CS.XiaWorld.Fight.g_emFightCamp.Player)
npc1:ChangeRank(CS.XiaWorld.g_emNpcRank.Worker)
me:AddMsg(""..name1.."接受了"..name2.."的劝说并决定加入这个坑爹的门派。。。")
end
else
me:AddMsg(""..name1.."没有接受"..name2.."的劝说并狠狠的骂了"..name2.."一顿！")
end
end

---------------------------------------------------------------------------------------------聊天


function Sheng:LiaoTianPD()
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
if npc1.Race.RaceType == npc2.Race.RaceType then
return true;
else
return false;
end
end

function Sheng:LiaoTian()
world:SetRandomSeed();
npc1 = ThingMgr:FindThingByID(story:GetBindThing().ID)
npc2 = ThingMgr:FindThingByID(me.npcObj.ID)
local name1 = npc1.Name;
local name2 = npc2.Name;
local value = Sheng:LiaoTiannumber(story:GetBindThing().ID,me.npcObj.ID)
local random = npc1.LuaHelper:RandomInt(1,100)
if value == 1.5 then
me:AddMsg(""..name1.."与"..name2.."相见恨晚，畅聊了许久，发现彼此都是如此合得来，双方好感度大幅提升！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"DeepTalk")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"DeepTalk")
elseif value == 1 then
me:AddMsg(""..name1.."与"..name2.."发现彼此都是如此的相似，许多事情都能聊到一起，双方好感度提升！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"AfterTalk")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"AfterTalk")
else
if random <= 50 then
me:AddMsg(""..name1.."认为"..name2.."和自己说话的语气十分锋利，感觉自己应该和他合不来！双方好感度小幅提升！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"AfterTalk")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"AfterTalk")
elseif random <=70 then
me:AddMsg(""..name1.."认为"..name2.."怠慢了自己，就和他吵了一架！双方好感度降低！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"Neglect")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"Neglect")
elseif random <=85 then
me:AddMsg(""..name1.."和"..name2.."因为一件事情大吵了一架，感觉自己肯定和他合不来！双方好感度降低！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"Quarrel")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"Quarrel")
elseif random <= 95 then
me:AddMsg(""..name1.."和"..name2.."因为一件事情大吵了一架并互相侮辱了对方，shit！双方好感度降低！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"Insult")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"Insult")
else
me:AddMsg(""..name1.."和"..name2.."因为一件事情动了火气并互相殴打了对方！双方好感度降低！");
npc1.PropertyMgr.RelationData:AddFavour(npc2,"AfterTalkFight")
npc2.PropertyMgr.RelationData:AddFavour(npc1,"AfterTalkFight")
end
end
end

function Sheng:LiaoTiannumber(AID,BID)
	local NanMing = Sheng:DanSuanMing(AID)
	local NvMing = Sheng:DanSuanMing(BID)
	local NanElement = Sheng:DanShuXing(""..NanMing.."");
	local NvElement = Sheng:DanShuXing(""..NvMing.."");
	local number = nil;
	if NanElement == "金" then
		if NvElement == "金" then
		number = 1;
		elseif NvElement == "木" then
		number = 0.5;
		elseif NvElement == "水" then
		number = 1.5;
		elseif NvElement == "火" then
		number = 1;
		else
		number = 1.5;
		end
	elseif NanElement == "木" then
		if NvElement == "金" then
		number = 0.5;
		elseif NvElement == "木" then
		number = 1;
		elseif NvElement == "水" then
		number = 1.5;
		elseif NvElement == "火" then
		number = 1.5;
		else
		number = 0.5;
		end
	elseif NanElement == "水" then
		if NvElement == "金" then
		number = 1.5;
		elseif NvElement == "木" then
		number = 1.5;
		elseif NvElement == "水" then
		number = 1;
		elseif NvElement == "火" then
		number = 1.5;
		else
		number = 1.5;
		end
	elseif NanElement == "火" then
		if NvElement == "金" then
		number = 1.5;
		elseif NvElement == "木" then
		number = 0.5;
		elseif NvElement == "水" then
		number = 0.5;
		elseif NvElement == "火" then
		number = 1;
		else
		number = 1.5;
		end
	else
		if NvElement == "金" then
		number = 1.5;
		elseif NvElement == "木" then
		number = 0.5;
		elseif NvElement == "水" then
		number = 0.5;
		elseif NvElement == "火" then
		number = 1.5;
		else
		number = 1;
		end		
	end
	return number;
end

----------------------------------------------------------------------------------------------算命

function Sheng:DanSuanMing(n)
	local npc = ThingMgr:FindThingByID(n);
	local age = npc.Age - npc.Age%1;
	local year = 2000 + World.YearCount;
	local BirthYear = year - age;
	local firstcount= (BirthYear%10) +  ((BirthYear%100 - BirthYear%10)/10) + (BirthYear/100 - ((BirthYear/100)%1) - (BirthYear/1000- BirthYear/1000%1)*10) + (BirthYear/1000- BirthYear/1000%1)
	local secondcount = nil;
	local thirdcount = nil;
	local count = nil;
	local MingGua = nil;
	if npc.Sex == CS.XiaWorld.g_emNpcSex.Male then
	secondcount = ( firstcount/10 -(firstcount/10)%1) + (firstcount -  (firstcount/10 -(firstcount/10)%1)*10);
	thirdcount = 11 - secondcount;
	count = thirdcount;
	else
	secondcount = ( firstcount/10 -(firstcount/10)%1) + (firstcount -  (firstcount/10 -(firstcount/10)%1)*10);
	thirdcount = secondcount + 4;
	if thirdcount > 9 then
	count = thirdcount -5;
	else
	count = thirdcount;
	end
	end
	if count == 1 then
	MingGua = "坎"
	elseif count == 2 then
	MingGua = "坤"
	elseif count == 3 then
	MingGua = "震"
	elseif count == 4 then
	MingGua = "巽"
	elseif count == 6 then
	MingGua = "乾"
	elseif count == 7 then
	MingGua = "兑"
	elseif count == 8 then
	MingGua = "艮"
	elseif count == 9 then
	MingGua = "离"
	else
	if npc.Sex == CS.XiaWorld.g_emNpcSex.Male then
	MingGua = "坤"
	else
	MingGua = "艮"
	end
	end
	return MingGua;
end

function Sheng:DanShuXing(MingGua)
	local Element = nil;
	if MingGua == "坎" then
	Element = "水";
	elseif MingGua == "乾" or MingGua == "兑" then
	Element = "金";
	elseif MingGua == "巽" or MingGua == "震" then
	Element = "木";
	elseif MingGua == "艮" or MingGua == "坤" then
	Element = "土";
	else
	Element = "火";
	end
	return Element;
end

function Sheng:ShengXiao(n)
	local Animal = {[0]="猴",[1]="鸡",[2]="狗",[3]="猪",[4]="鼠",[5]="牛",[6]="虎",[7]="兔",[8]="龙",[9]="蛇",[10]="马",[11]="羊"}
	local npc = ThingMgr:FindThingByID(n);
	local age = npc.Age - npc.Age%1;
	local year = 2000 + World.YearCount;
	local BirthYear = year - age;
	local SXyear = BirthYear - 1960;
	local count = SXyear%12;
	local animal = nil;
	animal = Animal[count]
	return animal;
end

function Sheng:HunPeinumber(nanID,nvID)
	local NanMing = Sheng:DanSuanMing(nanID)
	local NvMing = Sheng:DanSuanMing(nvID)
	local NanElement = Sheng:DanShuXing(""..NanMing.."");
	local NvElement = Sheng:DanShuXing(""..NvMing.."");
	local number = nil;
	if NanElement == "金" then
		if NvElement == "金" then
		number = -10;
		elseif NvElement == "木" then
		number = -5;
		elseif NvElement == "水" then
		number = 5;
		elseif NvElement == "火" then
		number = 0;
		else
		number = 10;
		end
	elseif NanElement == "木" then
		if NvElement == "金" then
		number = 10;
		elseif NvElement == "木" then
		number = 5;
		elseif NvElement == "水" then
		number = -5;
		elseif NvElement == "火" then
		number = 0;
		else
		number = -10;
		end
	elseif NanElement == "水" then
		if NvElement == "金" then
		number = 10;
		elseif NvElement == "木" then
		number = 5;
		elseif NvElement == "水" then
		number = 0;
		elseif NvElement == "火" then
		number = -5;
		else
		number = -10;
		end
	elseif NanElement == "火" then
		if NvElement == "金" then
		number = -10;
		elseif NvElement == "木" then
		number = 5;
		elseif NvElement == "水" then
		number = 0;
		elseif NvElement == "火" then
		number = -5;
		else
		number = 10;
		end
	else
		if NvElement == "金" then
		number = 10;
		elseif NvElement == "木" then
		number = -5;
		elseif NvElement == "水" then
		number = -10;
		elseif NvElement == "火" then
		number = 0;
		else
		number = 5;
		end		
	end
	return number;
end

function Sheng:RiLi()
me:AddMsg("天命轮以天苍246年作为天苍元年，配合先天八卦将一年分为四季，十二个月，一百一十二日。");
me:AddMsg("春季分为正月，二月，三月。")
me:AddMsg("其中正月为1-9天，二月为10-19天，三月为19-28天。")
me:AddMsg("夏季分为四月，五月，六月。")
me:AddMsg("其中四月为1-9天，五月为10-19天，六月为19-28天。")
me:AddMsg("秋季分为七月，八月，九月。")
me:AddMsg("其中七月为1-9天，八月为10-19天，九月为19-28天。")
me:AddMsg("冬季分为十月，十一月，十二月。")
me:AddMsg("其中十月为1-9天，十一月为10-19天，十二月为19-28天。")
me:TriggerStory("Story_TML")
end

function Sheng:SanNiangRi()
me:AddMsg("传说古时有一名叫三娘的女子，长得花容月貌，倾国倾城，一心想嫁一个如意郎君，厮守终生。可是，不知什么原因，三娘得罪了月老，三娘曾六次去恳求月老，为其牵红线，可月老就是不肯给三娘牵红线，致使三娘青丝熬成了白发，仍然待字闺中，独守空房，没有嫁出去。三娘对此事耿耿于怀，看着人家花开并蒂，枝结连理，出双入对，既羡慕又嫉妒，由妒而生恨，决定报复人间这些痴男怨女，凡在其求月老的日子结婚的人，就得不到幸福，注定聚少离多，子息缘薄，多不如愿，故而真三娘煞为凶日，民间在择日时都避而远之。");
me:AddMsg("倘若在每季的初三，初七，十三，十八，廿二，廿七中结婚，很可能会发生不好的事情。");
me:AddMsg("请各位尽量在良辰吉日中结婚，以免惨遭灭门。");
me:TriggerStory("Story_TML")
end

function Sheng:ShengXiaoJiRi()
me:AddMsg("在挑选良辰吉日的时候，同时也要注意生肖与该月份的适应性。")
me:AddMsg("鼠：宜正月，六月，七月，十二月结婚，忌三月，九月结婚。")
me:AddMsg("牛：宜四月，五月，十月，十一月结婚，忌二月，八月结婚。")
me:AddMsg("虎：宜二月，三月，八月，九月结婚，忌五月，十一月结婚。")
me:AddMsg("兔：宜正月，六月，七月，十二月结婚，忌四月，十月结婚。")
me:AddMsg("龙：宜四月，五月，十月，十一月结婚，忌正月，七月结婚。")
me:AddMsg("蛇：宜二月，三月，八月，九月结婚，忌六月，十二月结婚。")
me:AddMsg("马：宜正月，六月，七月，十二月结婚，忌三月，九月结婚。")
me:AddMsg("羊：宜四月，五月，十月，十一月结婚，忌二月，八月结婚。")
me:AddMsg("猴：宜二月，三月，八月，九月结婚，忌五月，十一月结婚。")
me:AddMsg("鸡：宜正月，六月，七月，十二月结婚，忌四月，十月结婚。")
me:AddMsg("狗：宜四月，五月，十月，十一月结婚，忌正月，七月结婚。")
me:AddMsg("猪：宜二月，三月，八月，九月结婚，忌六月，十二月结婚。")
me:TriggerStory("Story_TML")
end

function Sheng:ShiErShengXiao()
me:AddMsg("天命轮按照曾经仙界神兽的归位顺序，创造了十二生肖。根据十二属相之间相合、相冲、相克、相害、相生、相刑的规律而产生的一种相适性。")
me:AddMsg("十二生肖分别为以下：")
me:AddMsg("鼠，牛，虎，兔")
me:AddMsg("龙，蛇，马，羊")
me:AddMsg("猴，鸡，狗，猪")
me:TriggerStory("Story_TML")
end


function Sheng:WuXing()
me:AddMsg("每个人的出生时间不同，根据天地灵气等因素，导致每个人的命卦都不一样。")
me:AddMsg("其中每个卦数都对应了一个属性，不同属性的人会有不同的相适性。")
me:AddMsg("乾卦，兑卦：金属性");
me:AddMsg("离卦：火属性");
me:AddMsg("震卦，巽卦：木属性");
me:AddMsg("坎卦：水属性");
me:AddMsg("艮卦，坤卦：土属性");
me:TriggerStory("Story_TML")
end

function Sheng:daynumber(w)
local animal = Sheng:ShengXiao(w)
local allday =World.YearDayCount
local day = allday%112
local number = nil;
if animal == "鼠" then
if (day >= 1 and day <= 9) or (day >= 48 and day <= 56) or (day >= 57 and day <= 65) or ((day >= 104 and day <= 111) or day == 0) then
number = 10;
elseif (day >= 20 and day <= 28) or (day >= 76 and day <= 84) then
number = -10;
else
number = 0;
end
elseif animal == "牛" then
if (day >= 29 and day <= 37) or (day >= 38 and day <= 47) or (day >= 85 and day <= 93) or (day >= 94 and day <= 103) then
number = 10;
elseif (day >= 66 and day <= 75) or (day >= 10 and day <= 19) then
number = -10;
else
number = 0;
end
elseif animal == "虎" then
if (day >= 29 and day <= 37) or (day >= 38 and day <= 47) or (day >= 85 and day <= 93) or (day >= 94 and day <= 103) then
number = 10;
elseif (day >= 38 and day <= 47) or (day >= 94 and day <= 103) then
number = -10;
else
number = 0;
end
elseif animal == "兔" then
if (day >= 1 and day <= 9) or (day >= 48 and day <= 56) or (day >= 57 and day <= 65) or ((day >= 104 and day <= 111) or day == 0) then
number = 10;
elseif (day >= 29 and day <= 37) or (day >= 85 and day <= 93) then
number = -10;
else
number = 0;
end
elseif animal == "龙" then
if (day >= 29 and day <= 37) or (day >= 38 and day <= 47) or (day >= 85 and day <= 93) or (day >= 94 and day <= 103) then
number = 10;
elseif (day >= 1 and day <= 9) or (day >= 57 and day <= 65) then
number = -10;
else
number = 0;
end
elseif animal == "蛇" then
if (day >= 10 and day <= 19) or (day >= 20 and day <= 28) or (day >= 66 and day <= 75) or (day >= 76 and day <= 84) then
number = 10;
elseif (day >= 48 and day <= 56) or (day >= 85 and day <= 93) then
number = -10;
else
number = 0;
end
elseif animal == "马" then
if (day >= 1 and day <= 9) or (day >= 48 and day <= 56) or (day >= 57 and day <= 65) or ((day >= 104 and day <= 111) or day == 0) then
number = 10;
elseif (day >= 20 and day <= 28) or (day >= 76 and day <= 84) then
number = -10;
else
number = 0;
end
elseif animal == "羊" then
if (day >= 29 and day <= 37) or (day >= 38 and day <= 47) or (day >= 85 and day <= 93) or (day >= 94 and day <= 103) then
number = 10;
elseif (day >= 66 and day <= 75) or (day >= 10 and day <= 19) then
number = -10;
else
number = 0;
end
elseif animal == "猴" then
if (day >= 10 and day <= 19) or (day >= 20 and day <= 28) or (day >= 66 and day <= 75) or (day >= 76 and day <= 84) then
number = 10;
elseif (day >= 38 and day <= 47) or (day >= 94 and day <= 103) then
number = -10;
else
number = 0;
end
elseif animal == "鸡" then
if (day >= 1 and day <= 9) or (day >= 48 and day <= 56) or (day >= 57 and day <= 65) or ((day >= 104 and day <= 111) or day == 0) then
number = 10;
elseif (day >= 29 and day <= 37) or (day >= 85 and day <= 93) then
number = -10;
else
number = 0;
end
elseif animal == "狗" then
if (day >= 29 and day <= 37) or (day >= 38 and day <= 47) or (day >= 85 and day <= 93) or (day >= 94 and day <= 103) then
number = 10;
elseif (day >= 1 and day <= 9) or (day >= 57 and day <= 65) then
number = -10;
else
number = 0;
end
else
if (day >= 10 and day <= 19) or (day >= 20 and day <= 28) or (day >= 66 and day <= 75) or (day >= 76 and day <= 84) then
number = 10;
elseif (day >= 48 and day <= 56) or (day >= 85 and day <= 93) then
number = -10;
else
number = 0;
end
end
return number;
end

function Sheng:ShengXiaonumber(nanID,nvID)
local animal1 = Sheng:ShengXiao(nanID)
local animal2 = Sheng:ShengXiao(nvID)
local number = nil;
if animal1 == "鼠" then
if animal2 == "龙" then
number = 10;
elseif animal2 =="牛" then
number = 20;
elseif animal2 =="猴" then
number = 10;
elseif animal2 =="马" then
number = -20;
elseif animal2 =="羊" then
number = -10;
else
number = 0;
end
elseif animal1 == "牛" then
if animal2 == "鸡" then
number = 10;
elseif animal2 =="鼠" then
number = 20;
elseif animal2 =="蛇" then
number = 10;
elseif animal2 =="羊" then
number = -20;
elseif animal2 =="马" then
number = -10;
else
number = 0;
end
elseif animal1 == "虎" then
if animal2 == "马" then
number = 10;
elseif animal2 =="猪" then
number = 20;
elseif animal2 =="狗" then
number = 10;
elseif animal2 =="猴" then
number = -20;
elseif animal2 =="蛇" then
number = -10;
else
number = 0;
end
elseif animal1 == "兔" then
if animal2 == "猪" then
number = 10;
elseif animal2 =="狗" then
number = 20;
elseif animal2 =="羊" then
number = 10;
elseif animal2 =="鸡" then
number = -20;
elseif animal2 =="龙" then
number = -10;
else
number = 0;
end
elseif animal1 == "龙" then
if animal2 == "猴" then
number = 10;
elseif animal2 =="鸡" then
number = 20;
elseif animal2 =="鼠" then
number = 10;
elseif animal2 =="狗" then
number = -20;
elseif animal2 =="兔" then
number = -10;
else
number = 0;
end
elseif animal1 == "蛇" then
if animal2 == "牛" then
number = 10;
elseif animal2 =="猴" then
number = 20;
elseif animal2 =="鸡" then
number = 10;
elseif animal2 =="猪" then
number = -20;
elseif animal2 =="虎" then
number = -10;
else
number = 0;
end
elseif animal1 == "马" then
if animal2 == "虎" then
number = 10;
elseif animal2 =="羊" then
number = 20;
elseif animal2 =="狗" then
number = 10;
elseif animal2 =="鼠" then
number = -20;
elseif animal2 =="牛" then
number = -10;
else
number = 0;
end
elseif animal1 == "羊" then
if animal2 == "猪" then
number = 10;
elseif animal2 =="马" then
number = 20;
elseif animal2 =="兔" then
number = 10;
elseif animal2 =="牛" then
number = -20;
elseif animal2 =="鼠" then
number = -10;
else
number = 0;
end
elseif animal1 == "猴" then
if animal2 == "龙" then
number = 10;
elseif animal2 =="蛇" then
number = 20;
elseif animal2 =="鼠" then
number = 10;
elseif animal2 =="虎" then
number = -20;
elseif animal2 =="猪" then
number = -10;
else
number = 0;
end
elseif animal1 == "鸡" then
if animal2 == "牛" then
number = 10;
elseif animal2 =="龙" then
number = 20;
elseif animal2 =="蛇" then
number = 10;
elseif animal2 =="兔" then
number = -20;
elseif animal2 =="狗" then
number = -10;
else
number = 0;
end
elseif animal1 == "狗" then
if animal2 == "马" then
number = 10;
elseif animal2 =="兔" then
number = 20;
elseif animal2 =="虎" then
number = 10;
elseif animal2 =="龙" then
number = -20;
elseif animal2 =="鸡" then
number = -10;
else
number = 0;
end
else
if animal2 == "羊" then
number = 10;
elseif animal2 =="虎" then
number = 20;
elseif animal2 =="兔" then
number = 10;
elseif animal2 =="蛇" then
number = -20;
elseif animal2 =="猴" then
number = -10;
else
number = 0;
end
end
return number;
end

function Sheng:SanNiangnumber()
	local allday =World.YearDayCount;
	local day = allday%28;
	local number = nil;
	if day == 3 or day == 7 or day == 13 or day == 18 or day == 22 or day == 27 then
	number = -20;
	else
	number = 0;
	end
	return number;
end

function Sheng:BookCount()
	local id = me.npcObj.ID;
	local name = me.npcObj.Name;
	local age = me.npcObj.Age - me.npcObj.Age%1;
	local animal = Sheng:ShengXiao(id);
	local MingGua = Sheng:DanSuanMing(id);
	me:AddMsg("姓名:"..name.."");
	me:AddMsg("年龄:"..age.."      生肖:"..animal.."");
	me:AddMsg("命卦:"..MingGua.."卦");
	me:TriggerStory("Story_TML")
end

function Sheng:AllBookCount()
	local Count = Map.Things:GetActiveNpcs().Count;
	for i = 0 , Count - 1, 1 do
				local id = Map.Things:GetActiveNpcs()[i].ID;
				local npc = ThingMgr:FindThingByID(id)
				local name = npc.Name;
				local age = npc.Age - npc.Age%1;
				local animal = Sheng:ShengXiao(id);
				local MingGua = Sheng:DanSuanMing(id);
				me:AddMsg("姓名:"..name.."\n年龄:"..age.."      生肖:"..animal.."\n命卦:"..MingGua.."卦");
	end
	me:TriggerStory("Story_TML")
end

function Sheng:allnumber(nanID,nvID)
	local count = nil;
	count = Sheng:SanNiangnumber() + Sheng:daynumber(nanID) + Sheng:daynumber(nvID) + Sheng:HunPeinumber(nanID,nvID) + Sheng:ShengXiaonumber(nanID,nvID);
	return count;
end

---------------------------------------------------------------------------------------------
function Sheng:ZhuaZhouPD()
	if me:CheckFeature("YingEr") == true and me:GetFlag(2888) ~= 1 then
	return true;
	else
	return false;
	end
end


function Sheng:ZhuaZhou1()
	world:SetRandomSeed();
	local id = me.npcObj.ID;
	local npc = me.npcObj.PropertyMgr.SkillData;
	local random = me.npcObj.LuaHelper:RandomInt(1,16)
	if random == 1 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Qi,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Qi,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一本练气秘籍，将来[NAME]将在气感方面必成大器！");
	elseif random == 2 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Fight,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Fight,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一柄普通铁剑，将来[NAME]将在战斗方面必成大器！");
	elseif random == 3 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.SocialContact,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.SocialContact,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一只手帕，将来[NAME]将在社交方面必成大器！");
	elseif random == 4 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Medicine,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Medicine,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一株灵仙草，将来[NAME]将在岐黄方面必成大器！");
	elseif random == 5 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Cooking,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Cooking,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一块猪肉，将来[NAME]将在厨艺方面必成大器！");
	elseif random == 6 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Building,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Building,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一堆木材，将来[NAME]将在建筑方面必成大器！");
	elseif random == 7 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Farming,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Farming,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一把锄头，将来[NAME]将在种地方面必成大器！");
	elseif random == 8 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Mining,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Mining,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一把铁镐，将来[NAME]将在挖矿方面必成大器！");
	elseif random == 9 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Art,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Art,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一本诗集，将来[NAME]将在艺术方面必成大器！");
	elseif random == 10 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Manual,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Manual,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一柄木槌，将来[NAME]将在手艺方面必成大器！");
	elseif random == 11 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.DouFa,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.DouFa,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一本斗法秘籍，将来[NAME]将在斗法方面必成大器！");
	elseif random == 12 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.DanQi,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.DanQi,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一鼎炼器炉，将来[NAME]将在丹器方面必成大器！");
	elseif random == 13 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Fabao,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Fabao,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一柄玄光宝剑，将来[NAME]将在御器方面必成大器！");
	elseif random == 14 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.FightSkill,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.FightSkill,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一本神通秘籍，将来[NAME]将在术法方面必成大器！");
	elseif random == 15 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Barrier,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Barrier,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一个盾牌，将来[NAME]将在护体方面必成大器！");
	elseif random == 16 then
	npc:AddSkillLove(CS.XiaWorld.g_emNpcSkillType.Zhen,2)
	npc:AddSkillLevelOverAddion(CS.XiaWorld.g_emNpcSkillType.Zhen,5)
	me:AddMsg("只见[NAME]在抓周时将手伸向一个本关于阵法之道的书籍，将来[NAME]将在布阵方面必成大器！");
	else
	end
	me:SetFlag(2888,1)
end

function Sheng:ZhuaZhou2()
	if me:CheckFeature("YingEr") ~= true then
	me:AddMsg("[NAME]不是婴儿，不能抓周！");
	elseif me:GetFlag(2888) == 1 then
	me:AddMsg("[NAME]已经抓周过了，不能重复抓周！");
	else
	end
end

function Sheng:YingErPD()
	if me:CheckFeature("YingEr") == true and me.npcObj.PropertyMgr:FindModifier("TimeCold") == nil then
	return true;
	else
	return false;
	end
end

function Sheng:YingErS1()
	local npc = me.npcObj;
	me:AddMsg("[NAME]经过锻炼，身体比以往强壮了许多，根骨增加0.5！并且长大了一岁!");
	me.npcObj.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Physique,0.5);
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经五岁了！他从婴儿时期成长到孩童时期！")
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS2()
	local npc = me.npcObj;
	me:AddMsg("[NAME]经过观日，眼神比以往好使很多，神识增加0.5！并且长大了一岁!");
	me.npcObj.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Perception,0.5);
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经四岁了！他从婴儿时期成长到孩童时期！")
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS3()
	local npc = me.npcObj;
	me:AddMsg("[NAME]经过女装打扮，比以往好看了很多，魅力增加0.5！并且长大了一岁!");
	me.npcObj.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Charisma,0.5);
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经五岁了！他从婴儿时期成长到孩童时期！")
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS4()
	local npc = me.npcObj;
	me:AddMsg("[NAME]经过读三字经，脑子比以往灵活多了，悟性增加0.5！并且长大了一岁!");
	me.npcObj.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Intelligence,0.5);
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经五岁了！他从婴儿时期成长到孩童时期！")
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS5()
	local npc = me.npcObj;
	me:AddMsg("[NAME]经过做梦，貌似运气比以往好多了，运气增加0.5！并且长大了一岁!");
	me.npcObj.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Luck,0.5);
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经五岁了！他从婴儿时期成长到孩童时期！");
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS6()
	local npc = me.npcObj;
	me:AddMsg("[NAME]啥也没做，所以什么也没发生，但是长大了一岁!");
	me.npcObj.PropertyMgr:AddAge(1);
	npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 5 then
	me:AddMsg("[NAME]已经五岁了！他从婴儿时期成长到孩童时期！")
	npc.PropertyMgr:RemoveFeature("YingEr");
	npc.PropertyMgr:RemoveModifier("YingErShi");
	npc.PropertyMgr:AddFeature("HaiTong");
	end
end

function Sheng:YingErS7()
	me:AddMsg("[NAME]不是婴儿，不能进入婴儿培养室里！")
end


function Sheng:HaiTongPD()
	if me:CheckFeature("HaiTong") == true and me.npcObj.PropertyMgr:FindModifier("TimeCold") == nil  then
	return true;
	else
	return false;
	end
end

function Sheng:HaiTongS1()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高气感之事，气感+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Qi,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS2()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高战斗之事，战斗+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Fight,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS3()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高社交之事，社交+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.SocialContact,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS4()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高医学之事，岐黄+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Medicine,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS5()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高厨艺之事，厨艺+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Cooking,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS6()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高筑工之事，筑工+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Building,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS7()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高农耕之事，农耕+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Farming,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS8()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高挖矿之事，采矿+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Mining,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS9()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高艺术之事，艺术+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Art,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS10()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高手工之事，手艺+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Manual,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS11()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高斗法之事，斗法+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.DouFa,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS12()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高丹器之事，丹器+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.DanQi,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS13()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高御器之事，御器+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Fabao,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS14()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高术法之事，术法+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.FightSkill,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:HaiTongS15()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高护体之事，护体+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Barrier,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end



function Sheng:HaiTongS16()
	me:AddMsg("[NAME]不是孩童，不能进行孩童之时的训练！");
end

function Sheng:HaiTongS17()
	local Npc = me.npcObj;
	local npc = me.npcObj.PropertyMgr.SkillData;
	me:AddMsg("[NAME]在这一年里做了许多提高阵法领悟之事，阵法+3！并且年龄增加了一岁！");
	npc:AddSkillLevelAddion(CS.XiaWorld.g_emNpcSkillType.Zhen,3);
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 11 then
	me:AddMsg("[NAME]已经十一岁了！他从孩童时期成长到少年时期！")
	Npc.PropertyMgr:RemoveFeature("HaiTong");
	Npc.PropertyMgr:AddFeature("ShaoNian");
	end
end

function Sheng:ShaoNianPD()
	if me:CheckFeature("ShaoNian") == true and me.npcObj.PropertyMgr:FindModifier("TimeCold") == nil  then
	return true;
	else
	return false;
	end
end

function Sheng:ShaoNianS1()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过灵气训练，灵气恢复速度提高400%，根本灵气最大值提高100！并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("LingAbsorbSpeed",4,0); 
	Npc.PropertyMgr:ModifierProperty("NpcLingMaxValue",0,0,100,0); 
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end


function Sheng:ShaoNianS2()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过心境训练，心境基础值提高8点，修炼速度增加50%！并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("MindStateBaseValue",8,0); 
	Npc.PropertyMgr:ModifierProperty("DeepPracticeSpeedSpecialCoefficient",0.5,0); 
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end

function Sheng:ShaoNianS3()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过炼器训练，炼器成功率提高5%，炼器质量提高8%，炼器速度提高10%，炼器品阶提高8%！并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("FabaoMake_SuccessRateAddV",0.05,0); 
	Npc.PropertyMgr:ModifierProperty("FabaoMake_QualityAddV",0.08,0); 
	Npc.PropertyMgr:ModifierProperty("FabaoMake_SpeedAddV",0.1,0); 
	Npc.PropertyMgr:ModifierProperty("FabaoMake_LingInheritRateAddV",0.08,0); 
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end

function Sheng:ShaoNianS4()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过炼丹训练，炼丹成功率提高8%，炼丹产量提高5%，炼丹速度提高10%！并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("DanMake_YieldAddP",0.05,0); 
	Npc.PropertyMgr:ModifierProperty("DanMake_SuccessRateAddV",0.08,0); 
	Npc.PropertyMgr:ModifierProperty("DanMake_SpeedAddV",0.1,0); 
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end

function Sheng:ShaoNianS5()
	me:AddMsg("[NAME]不是少年，不能进行少年时期的训练！");
end

function Sheng:ShaoNianS6()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过阵法训练，习得了大量的阵法之道，此人作为阵枢时，阵法稳定性将稍微提高，并且其所能布置阵法规模比以往更大了！并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("NpcFight_ZhenKeyPointNum",1,0); 
	Npc.PropertyMgr:ModifierProperty("NpcFight_ZhenEnginePower",8,0); 
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end

function Sheng:ShaoNianS7()
	local Npc = me.npcObj;
	me:AddMsg("[NAME]经过潜行训练，习得了大量的屏息移动之道，其气息稳定性以及移动速度提高了。并且年龄增加一岁！");
	Npc.PropertyMgr:ModifierProperty("NpcFight_SneakValue",15,0); 
	Npc.PropertyMgr:ModifierProperty("MoveSpeed",0.5,0); 
	me.npcObj.PropertyMgr:AddAge(1);
	Npc.PropertyMgr:AddModifier("TimeCold");
	if me:GetAge() >= 18 then
	me:AddMsg("[NAME]已经十八岁了！他从少年成长到成人了！")
	Npc.PropertyMgr:RemoveFeature("ShaoNian");
	end
end

function Sheng:RemoveNewMan()
	local npc = me.npcObj;
	if npc.PropertyMgr:FindModifier("NewMan") ~= nil then
	npc.PropertyMgr:RemoveModifier("NewMan");
	me:AddMsg("随着一道光芒，[NAME]身上的新婚服装消失了。")
	elseif npc.PropertyMgr:FindModifier("NewWoMan") ~= nil then
	npc.PropertyMgr:RemoveModifier("NewWoMan");
	me:AddMsg("随着一道光芒，[NAME]身上的新婚服装消失了。")
	else
	me:AddMsg("[NAME]并没有身穿新婚服装。")
	end
end


-------------------------------------------------------------------------------------------联机互动

function Sheng:OnReceiveData(data,Sender)
local msgdata = Lib:Unserialize(CS.System.Convert.FromBase64String(data))
local npc = CS.XiaWorld.NpcRandomMechine.RandomNpc("Human");
CS.XiaWorld.NpcMgr.Instance:AddNpc(npc,CS.XiaWorld.World.Instance.map:RandomBronGrid(),Map,CS.XiaWorld.Fight.g_emFightCamp.Player);
local Skill = npc.PropertyMgr.SkillData;
local g_emNpcSkillType = CS.XiaWorld.g_emNpcSkillType;
npc.PropertyMgr.Age = 1;
npc.HairID = msgdata["HairID"]
if msgdata["Sex"] == "Male" then
npc.PropertyMgr:SetSex(CS.XiaWorld.g_emNpcSex.Male)
else
npc.PropertyMgr:SetSex(CS.XiaWorld.g_emNpcSex.Female)
end
npc:ChangeRank(CS.XiaWorld.g_emNpcRank.Worker);
npc.PropertyMgr:ChangeName(msgdata["PreName"],msgdata["SufName"])

npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Perception,msgdata["Perception"] - npc.LuaHelper:GetPerception());
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Physique,msgdata["Physique"] - npc.LuaHelper:GetPhysique());
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Charisma,msgdata["Charisma"] - npc.LuaHelper:GetCharisma());
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Intelligence,msgdata["Intelligence"] - npc.LuaHelper:GetIntelligence());
npc.PropertyMgr.BaseData:AddAddion(CS.XiaWorld.g_emNpcBasePropertyType.Luck,msgdata["Luck"] - npc.LuaHelper:GetLuck());

Skill:AddSkillLevelAddion(g_emNpcSkillType.Qi,msgdata["Qi"] - Skill:GetSkillLevel(g_emNpcSkillType.Qi));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Fight,msgdata["Fight"] - Skill:GetSkillLevel(g_emNpcSkillType.Fight));
Skill:AddSkillLevelAddion(g_emNpcSkillType.SocialContact,msgdata["SocialContact"] - Skill:GetSkillLevel(g_emNpcSkillType.SocialContact));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Medicine,msgdata["Medicine"] - Skill:GetSkillLevel(g_emNpcSkillType.Medicine));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Cooking,msgdata["Cooking"] - Skill:GetSkillLevel(g_emNpcSkillType.Cooking));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Building,msgdata["Building"] - Skill:GetSkillLevel(g_emNpcSkillType.Building));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Farming,msgdata["Farming"] - Skill:GetSkillLevel(g_emNpcSkillType.Farming));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Mining,msgdata["Mining"] - Skill:GetSkillLevel(g_emNpcSkillType.Mining));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Art,msgdata["Art"] - Skill:GetSkillLevel(g_emNpcSkillType.Art));
Skill:AddSkillLevelAddion(g_emNpcSkillType.Manual,msgdata["Manual"] - Skill:GetSkillLevel(g_emNpcSkillType.Manual));
Skill:AddSkillLevelAddion(g_emNpcSkillType.DouFa,msgdata["DouFa"] - Skill:GetSkillLevel(g_emNpcSkillType.DouFa));
Skill:AddSkillLevelAddion(g_emNpcSkillType.DanQi,msgdata["DanQi"] - Skill:GetSkillLevel(g_emNpcSkillType.DanQi));
npc.PropertyMgr:AddFeature(msgdata["Mother"]);
npc.PropertyMgr:AddFeature(msgdata["Father"]);
npc.PropertyMgr:AddFeature("GuEr");
npc.PropertyMgr:AddFeature("YingEr");
npc:AddModifier("YingErShi")
npc.view.needUpdateMod = true;
world:ShowMsgBox("遗弃在孤儿院的孤儿被门派【"..Sheng:GetMenPai().."】领养。","领养孤儿")
CS.XiaWorld.MessageMgr.Instance:AddChainEventMessage(18, -1, "传闻门派【"..Sheng:GetMenPai().."】慈悲大发，在孤儿院中领养了一位孤儿，一时间此举传遍周围门派，周围门派都对此称赞可嘉。", 0, 0, nil, "喜结良缘", -1);
end

function Sheng:MakeMsg(id,motherf,fatherf)
local npc = ThingMgr:FindThingByID(id)
local Skill = npc.PropertyMgr.SkillData;
local g_emNpcSkillType = CS.XiaWorld.g_emNpcSkillType;
local schoolname = SchoolMgr.Prefix..SchoolMgr.Suffix
local ffname = NpcMgr.FeatureMgr:GetDef(fatherf).DisplayName;
local mfname = NpcMgr.FeatureMgr:GetDef(motherf).DisplayName;
local msgdata = {}
local tippopinfo = nil;
local name = npc.Name;
local sex = nil;
msgdata["HairID"] = npc.HairID
if npc.Sex == CS.XiaWorld.g_emNpcSex.Male then
msgdata["Sex"] = "Male"
sex = "男性"
else
msgdata["Sex"] = "Female"
sex = "女性"
end
msgdata["PreName"] = npc.PropertyMgr.PrefixName
msgdata["SufName"] = npc.PropertyMgr.SuffixName
msgdata["Perception"] = npc.LuaHelper:GetPerception()
msgdata["Physique"] = npc.LuaHelper:GetPhysique()
msgdata["Charisma"] = npc.LuaHelper:GetCharisma()
msgdata["Intelligence"] = npc.LuaHelper:GetIntelligence()
msgdata["Luck"] = npc.LuaHelper:GetLuck()
msgdata["Qi"] = Skill:GetSkillLevel(g_emNpcSkillType.Qi)
msgdata["Fight"] = Skill:GetSkillLevel(g_emNpcSkillType.Fight)
msgdata["SocialContact"] = Skill:GetSkillLevel(g_emNpcSkillType.SocialContact)
msgdata["Medicine"] = Skill:GetSkillLevel(g_emNpcSkillType.Medicine)
msgdata["Cooking"] = Skill:GetSkillLevel(g_emNpcSkillType.Cooking)
msgdata["Building"] = Skill:GetSkillLevel(g_emNpcSkillType.Building)
msgdata["Farming"] = Skill:GetSkillLevel(g_emNpcSkillType.Farming)
msgdata["Mining"] = Skill:GetSkillLevel(g_emNpcSkillType.Mining)
msgdata["Art"] = Skill:GetSkillLevel(g_emNpcSkillType.Art)
msgdata["Manual"] = Skill:GetSkillLevel(g_emNpcSkillType.Manual)
msgdata["DouFa"] = Skill:GetSkillLevel(g_emNpcSkillType.DouFa)
msgdata["DanQi"] = Skill:GetSkillLevel(g_emNpcSkillType.DanQi)
msgdata["Mother"] = motherf
msgdata["Father"] = fatherf
local a = npc.LuaHelper:GetPerception() - npc.LuaHelper:GetPerception()%0.01
local b = npc.LuaHelper:GetPhysique() - npc.LuaHelper:GetPhysique()%0.01
local c = npc.LuaHelper:GetCharisma() - npc.LuaHelper:GetCharisma()%0.01
local d = npc.LuaHelper:GetIntelligence() - npc.LuaHelper:GetIntelligence()%0.01
local e = npc.LuaHelper:GetLuck() - npc.LuaHelper:GetLuck()%0.01
tippopinfo = "[color=#0000CD]来自【"..schoolname.."】的门派弃婴。[/color]\n[color=#DC143C]姓名："..name.."   性别："..sex.."[/color]\n[color=#800080]来自父亲的特性【"..ffname.."】\n来自母亲的特性【"..mfname.."】[/color]\n[color=#F58630]【神识】"..a.."   \n【根骨】"..b.."    \n【魅力】"..c.."    \n【悟性】"..d.."   \n【机缘】"..e.."[/color]";
local data = Lib:Serialize(msgdata)
local msg = string.format('{"InfantName":"%s","InfantData":"%s","TipPopInfo":"%s"}',name,CS.System.Convert.ToBase64String(data),CS.System.Convert.ToBase64String(tippopinfo))
XChat:SendMsg2("LiangYuan",msg)
end

function Sheng:GetGuEr()
	if CS.ModsMgr.Instance:FindMod("XChat_Dev") ~= nil and GameMain:GetMod("XWebSocket").ws  then
	OrphanageWindow:Show()
	else
	me:AddMsg("没有安装【新修真聊天群MOD】无法使用领养功能或者没有连接服务器。");
	end
end
