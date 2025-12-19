local Windows = GameMain:GetMod("Windows");--先注册一个新的MOD模块
OrphanageWindow = Windows:CreateWindow("OrphanageWindow");
function OrphanageWindow:OnInit()
	OrphanageWindow.window.contentPane = UIPackage.CreateObject("Orphanage", "OrphanageWindow");--载入UI包里的窗口
	OrphanageWindow.window.closeButton = self:GetChild("frame"):GetChild("n5");
	OrphanageWindow.List = OrphanageWindow:GetChild("n2");
	OrphanageWindow.List.onClickItem:Add(OrphanageWindow.onClickItem);
	OrphanageWindow:GetChild("n3").onClick:Add(OrphanageWindow.Refresh);
	self.window:Center();
end

function OrphanageWindow:OnEnter()
end

function OrphanageWindow:OnShowUpdate()
	OrphanageWindow.isShowing = true;
	--self:UpdateData();
end

function OrphanageWindow:OnShown();
	OrphanageWindow.isShowing = true
	OrphanageWindow.Refresh();
end

function OrphanageWindow:OnUpdate()

end

function OrphanageWindow:OnHide()
	OrphanageWindow.isShowing = false;
end

function OrphanageWindow.onClickItem(Context)
	local Infant = Context.data;
	XChat:SendMsg2("GetAdopter",Infant.name)
end

function OrphanageWindow.Refresh()
	OrphanageWindow.List:RemoveChildrenToPool();
	OrphanageWindow.List:AddItemFromPool("ui://t11thi1orw7u4")
	XChat:SendMsg2("GetAdopterList","{}")
end

function OrphanageWindow:UpdateAdopterList(RawData)
	--RawData = [[{{ID="81130", From="我是院长", InfantName="申盼夏凤", tooltips="<font color='#f00f17'>来自【鸽子洞】的门派弃婴。姓名：申盼夏凤     性别：女性来自父亲的特性：【乐观】来自母亲的特性：【灵性】【神识】10.0   【根骨】6.9499998092651    【魅力】9.75    【悟性】10.0   【机缘】7.1999998092651</font>"},{ID="81131",From="我是院长",InfantName="申盼夏巽",tooltips="<font color='#f00f17'>来自【鸽子洞】的门派弃婴。姓名：申盼夏巽     性别：男性来自父亲的特性：【读书人】来自母亲的特性：【女汉子】【神识】9.0   【根骨】8.9499998092651    【魅力】7.75    【悟性】8.0   【机缘】8.1999998092651</font>"},{ID="81132",From="我是院长",InfantName="申盼夏宇",tooltips="<font color='#f00f17'>来自【鸽子洞】的门派弃婴。姓名：申盼夏宇     性别：女性来自父亲的特性：【命运之子】来自母亲的特性：【灵性】【神识】7.0   【根骨】7.9499998092651    【魅力】9.75    【悟性】10.0   【机缘】6.1999998092651</font>"},{ID="81133",From="我是院长",InfantName="申盼夏伟",tooltips="<font color='#f00f17'>来自【鸽子洞】的门派弃婴。姓名：申盼夏伟     性别：男性来自父亲的特性：【读书人】来自母亲的特性：【灵性】【神识】7.0   【根骨】5.9499998092651    【魅力】9.75    【悟性】10.0   【机缘】6.1999998092651</font>"},{ID="81134",From="我是院长",InfantName="申盼夏秋",tooltips="<font color='#f00f17'>来自【鸽子洞】的门派弃婴。姓名：申盼夏秋     性别：女性来自父亲的特性：【乐观】来自母亲的特性：【灵性】【神识】10.0   【根骨】7.9499998092651    【魅力】9.75    【悟性】10.0   【机缘】8.1999998092651</font>"}}]]
	
	OrphanageWindow.List:RemoveChildrenToPool();
	OrphanageWindow.List:AddItemFromPool("ui://t11thi1orw7u4")
	local AdopterList = load("return "..RawData)()
	for i=1,#AdopterList do
		local item = OrphanageWindow.List:AddItemFromPool();
		item.name = AdopterList[i].ID;
		item:GetChild("From").text = AdopterList[i].From;
		item:GetChild("InfantName").text = AdopterList[i].InfantName;
		item.tooltips = CS.System.Convert.FromBase64String(AdopterList[i].tooltips);
	end
end