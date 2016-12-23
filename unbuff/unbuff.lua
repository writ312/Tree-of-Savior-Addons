_G.ADDONS = _G.ADDONS or {};
_G.ADDONS.YYU = _G.ADDONS.YYU or {};
_G.ADDONS.YYU.UNBUFF = _G.ADDONS.YYU.UNBUFF or {};
local Unbuff = _G.ADDONS.YYU.UNBUFF;

-- Skill Tables
Unbuff.skillTable = {};
Unbuff.targetBuffIDTable = {};
local addUnbuffTable = function(Unbuff, name, classID, buffID)
	Unbuff.skillTable[name] =classID;
	Unbuff.targetBuffIDTable[classID] = buffID;
end
addUnbuffTable(Unbuff, "summoning",  20701, 3038);
addUnbuffTable(Unbuff, "levitation", 21107, 3070);



function Unbuff.hook(frame, slot, argStr, argNum)
	if GetCraftState() == 1 then
		return;
	end

	tolua.cast(slot, 'ui::CSlot');
	local icon = slot:GetIcon();
	if icon == nil then
		return;
	end

	local iconInfo = icon:GetInfo();

	local g = _G.ADDONS.YYU.UNBUFF;

	if iconInfo.category == 'Skill' then
		skl = GetIES(session.GetSkill(iconInfo.type):GetObject());

		local buffID = g.getBuffID(g, skl);
		if buffID ~= nil then
			packet.ReqRemoveBuff(buffID);
			return;
		end
	end

	g.oldHook(frame, slot, argStr, argNum)
end


function Unbuff.getBuffIDTraceOff(g, skl)
	local targetBuffID = g.targetBuffIDTable[skl.ClassID];
	if skl ~= nil and g.hasBuff(targetBuffID) then
		return targetBuffID;
	end

	return nil;
end


function Unbuff.getBuffIDTraceOn(g, skl)

	if skl ~= nil then
		local log = '[Unbuff] TRACE INFO{nl}';
		log = log .. 'SkillName:' .. skl.ClassName .. '{nl}';
		log = log .. 'SkillID:' .. skl.ClassID .. '{nl}';

		local handle = session.GetMyHandle();
		for i = 0, info.GetBuffCount(handle) - 1 do
			local buff = info.GetBuffIndexed(handle, i);
			log = log .. ' Buff ID at ' .. i .. ' = ' .. buff.buffID .. '{nl}';
		end
		
		CHAT_SYSTEM(log);
	end

	return g.getBuffIDTraceOff(g, skl);
end


function Unbuff.unbuff(g, skillClassID)
	local buffID = g.getBuffIDTraceOff(g, { ClassID = skillClassID });
	if buffID ~= nil then
		packet.ReqRemoveBuff(buffID);
	end
end


function Unbuff.hasBuff(targetBuffID)
	if targetBuffID ~= nil then
		local handle = session.GetMyHandle();
		for i = 0, info.GetBuffCount(handle) - 1 do
			if targetBuffID == info.GetBuffIndexed(handle, i).buffID then
				return true;
			end
		end
	end

	return false;
end


function Unbuff.commandHandler(commands)
	local g = _G.ADDONS.YYU.UNBUFF;
	local arg = string.lower(commands[1] or '');

	if arg == 'traceon' then
		g.getBuffID = g.getBuffIDTraceOn;
		CHAT_SYSTEM('[Unbuff] Trace ON.');
	elseif arg == 'traceoff' then
		g.getBuffID = g.getBuffIDTraceOff;
		CHAT_SYSTEM('[Unbuff] Trace OFF.');
	else
		local skillClassID = tonumber(arg);
		if skillClassID ~= nil then
			g.unbuff(g, skillClassID);
		else
			for name, classID in pairs(g.skillTable) do
				if string.find(name, arg, 1, true) == 1 then
					g.unbuff(g, classID);
					return;
				end
			end
		end
	end
end



if _G.UNBUFF_ON_INIT ~= nil then
	CHAT_SYSTEM('[Unbuff] WARNING: UNBUFF_ON_INIT is defined.');
end

function UNBUFF_ON_INIT(addon, frame)
	local g = _G.ADDONS.YYU.UNBUFF;

	if g.oldHook == nil then
		-- Setup Hook
		g.oldHook = _G.QUICKSLOTNEXPBAR_SLOT_USE;
		_G.QUICKSLOTNEXPBAR_SLOT_USE = g.hook;
		g.getBuffID = g.getBuffIDTraceOff;

		-- Setup Slash Command
		_G.ADDONS.YYU.Util.slashCommand('/unbuff', g.commandHandler);

		CHAT_SYSTEM('Unbuff loaded.');
	end
end
