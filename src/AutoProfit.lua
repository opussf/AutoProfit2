----------------------------------------------------------------
--	AutoProfit v4.5 (May 2007)
--	Check out www.gameguidesonline.com for the latest version.
--	To learn how I used the 3D model read this: (http://www.gameguidesonline.com/guides/articles/ggoarticleoctober05_02.asp)
--	Written by Jason Allen.
----------------------------------------------------------------
--  Fan Update (May 2007)
--  Added an /autoprofit destroy command that lets you junk all your vendor
--  trash.  Reorganized the code considerably.
--  (update by Paul Driver)
----------------------------------------------------------------
--  Fan Update


autoProfitExceptions = { };
autoProfitOptions = {["autoSell"] = 0, ["autoAnnounce"] = 1, ["totalProfit"] = 0};

AP = {};
AP.totalProfit = 0;
AUTOPROFIT_VERSION = "v@VERSION@";

function AP.Print(arg1, arg2)
	local caption = "";
	local message = "";

	if (arg2) then
		caption = arg1;
		message = arg2;
	else
		caption = "AutoProfit";
		message = arg1;
	end
	DEFAULT_CHAT_FRAME:AddMessage("|c00bfffff" .. caption .. "|r: " .. message, 0.0, .8, 1)
end

function AP.OnLoad()
	SLASH_AUTOPROFIT1 = "/autoprofit";
	SLASH_AUTOPROFIT2 = "/ap";
	SlashCmdList["AUTOPROFIT"] = AP.SlashCmd;

	AutoProfit:RegisterEvent("MERCHANT_SHOW");
	--AutoProfit:RegisterEvent("MERCHANT_CLOSED");
	--ap.ForAllJunk();
end

function AP.MERCHANT_SHOW()
	AP.SellJunk();
end

function AP.ForAllJunk(action, message)
	local total_value = 0;
	for bag = 0, 4 do
		if GetContainerNumSlots(bag) > 0 then
			for slot = 0, GetContainerNumSlots(bag) do
				local texture, itemCount, locked, quality, readable, _, link =
						GetContainerItemInfo(bag, slot);
				if (quality) then
					local sell = AP.Sell(link);
					if (sell and autoProfitOptions["autoSell"] == 1) then
						--ap.Print(bag..":"..slot..":"..itemCount.."x"..link);
						--ap.Print("Sell this");
						if (message and autoProfitOptions["autoAnnounce"] == 1) then
							AP.Print(message(bag, slot));
						end
						total_value = total_value + (action(bag, slot) * itemCount);
					end
				end

			end -- for slot
		end -- if bag
	end -- for bag
	return total_value;
end

function AP.SellJunk()
	local total_sold = AP.ForAllJunk(
		function(bag, slot)  -- action
			local _, _, _, _, _, _, link = GetContainerItemInfo(bag, slot);
			local _,_, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(link);
			UseContainerItem(bag, slot);
			return vendorPrice;
		end,
		function(bag, slot)
			return "Sold " .. GetContainerItemLink(bag, slot);
		end);
	if (total_sold>0 and autoProfitOptions["autoAnnounce"] == 1 and autoProfitOptions["autoSell"] == 1) then
		AP.Print("Profit", AP.MoneyFormat(total_sold));
	end
end

function AP.MoneyFormat(copperIn)
	return GetCoinTextureString(copperIn);
end

function AP.Usage()
  p = AP.Print;
  p(AUTOPROFIT_VERSION .. " by Jason Allen.");
  p("Update by Paul Driver");
  p("Update by OpusSF");
  p("/autoprofit [item link]", "Add or remove an item to the exception list.");
  p("/autoprofit list", "List all items on your exception list.");
  p("/autoprofit [number]",
    "Remove item at that location in your exception list");
  p("/autoprofit purge", "Remove all items from your exception list.");
  p("/autoprofit silent", "Toggles sale reporting on and off.");
  p("/autoprofit auto", "Toggles automatic selling on and off.");
end

--No switch statement in Lua? Use a jump table instead!--
AP.SlashCmd_switches = {
	[""] = AP.Usage,
	["purge"] = function ()
			autoProfitExceptions = { };
			AP.Print("Deleted all exceptions.");
		end,
	["auto"] = function ()
			local s = "off"
			if (autoProfitOptions["autoSell"] == 1) then
				autoProfitOptions["autoSell"] = 0;
			else
				autoProfitOptions["autoSell"] = 1;
				s = "on";
			end
			AP.Print("Automatic selling " .. s);
		end,
	["silent"] = function ()
			local s = "off"
			if (autoProfitOptions["autoAnnounce"] == 1) then
				autoProfitOptions["autoAnnounce"] = 0;
			else
				autoProfitOptions["autoAnnounce"] = 1;
				s = "on";
			end
			AP.Print("Sale reporting " .. s)
			end,
	["list"] = function ()
			if (table.getn(autoProfitExceptions) > 0) then
				AP.Print("AutoProfit Exceptions", "")
				for i=1, table.getn(autoProfitExceptions) do
					AP.Print(i, autoProfitExceptions[i])
				end
			else
				AP.Print("Your exceptions list is empty.")
			end
			end,
}

function AP.SlashCmd(msg)
	local s = AP.SlashCmd_switches;
	if (type(s[msg])=="function") then
		s[msg]();
	else
		if (string.len(msg) < 6) then
			local n = tonumber(msg);
			if (n == nil) then return; end
			if (n > table.getn(autoProfitExceptions)) then return; end
			AP.Print("Removed " .. autoProfitExceptions[n] ..
					" from exceptions list.");
			table.remove(autoProfitExceptions, n)
		else
			if (string.find(msg, "Hitem:") == nil) then return; end
			local removed = 0;
			if (table.getn(autoProfitExceptions) > 0) then
				for i=1, table.getn(autoProfitExceptions) do
					if (msg == autoProfitExceptions[i]) then
						AP.Print("Removed " .. autoProfitExceptions[i] ..
								" from exceptions list.");
						table.remove(autoProfitExceptions, i);
						removed = 1;
					end
				end
			end
			if (removed == 0) then
				table.insert(autoProfitExceptions, msg)
				AP.Print("Added " .. msg .. " to exceptions list.")
			end
		end
	end
end

function AP.Sell(link)
	-- name, link, rarity/quality (0-7), ilvL, minLvl, class/type, subclass/subtype, stackCount, EquipLoc, Texture, SellPrice = GetItemInfo()
	local name, _, quality, _, _, class, subclass = GetItemInfo(link);
	--AP.Print(name..":"..quality..":"..class..":"..subclass);
	if (quality == 0) then
		for i=1, table.getn(autoProfitExceptions) do
			if (link == autoProfitExceptions[i]) then
				return nil;
			end
		end
		return 1;
	end
	if (quality == 1) then
		for i=1, table.getn(autoProfitExceptions) do
			if (link == autoProfitExceptions[i]) then
				return 1;
			end
		end
		return nil;
	end
end

function AP.OptionsOnLoad(frame)
	frame.name = "AutoProfit";

	AutoProfit_Options_Title:SetText(frame.name .. " " .. AUTOPROFIT_VERSION);

	InterfaceOptions_AddCategory(frame);
end

