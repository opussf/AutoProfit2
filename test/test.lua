#!/usr/bin/env lua

addonData = { ["version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "AutoProfit"

AutoProfit = CreateFrame()

function test.before()
	 myInventory = { ["7073"] = 52, ["9799"] = 52, ["9999"] = 52, }
	 autoProfitExceptions = { }
	 AP.OnLoad()
end

function test.after()
end
function test.test_Print_DefaultCaption()
	AP.Print( "msg" )
end
function test.test_Print_GivenCaption()
	AP.Print( "msg", "caption" )
end
function test.test_Print_GivenCaption_02()
	AP.Print( "msg", "" )
end
function test.test_SlashCmd_Usage()
	AP.SlashCmd( "" )
end
function test.test_SlashCmd_Purge()
	autoProfitExceptions = {
		"|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r", -- [1]
		"|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", -- [2]
	}
	AP.SlashCmd( "purge" )
	assertEquals( 0, #autoProfitExceptions )
end
function test.test_SlashCmd_Auto_toOn()
	autoProfitOptions["autoSell"] = 0
	AP.SlashCmd( "auto" )
	assertEquals( 1, autoProfitOptions["autoSell"] )
end
function test.test_SlashCmd_Auto_toOff()
	autoProfitOptions["autoSell"] = 1
	AP.SlashCmd( "auto" )
	assertEquals( 0, autoProfitOptions["autoSell"] )
end
function test.test_SlashCmd_Silent_toOn()
	autoProfitOptions["autoAnnounce"] = 0
	AP.SlashCmd( "silent" )
	assertEquals( 1, autoProfitOptions["autoAnnounce"] )
end
function test.test_SlashCmd_Silent_toOff()
	autoProfitOptions["autoAnnounce"] = 1
	AP.SlashCmd( "silent" )
	assertEquals( 0, autoProfitOptions["autoAnnounce"] )
end
function test.test_SlashCmd_List_Empty()
	AP.SlashCmd( "list" )
end
function test.test_SlashCmd_List_HasItems()
	autoProfitExceptions = {
		"|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r", -- [1]
		"|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", -- [2]
	}
	AP.SlashCmd( "list" )
end
function test.test_SlashCmd_RemoveNumber_Empty()
	AP.SlashCmd( 1 )
	assertEquals( 0, #autoProfitExceptions )
end
function test.test_SlashCmd_RemoveNumber_OutOfRange()
	autoProfitExceptions = {
		"|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r", -- [1]
		"|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", -- [2]
	}
	AP.SlashCmd( "3" )
	assertEquals( 2, #autoProfitExceptions )
end
function test.test_SlashCmd_RemoveNumber_InRange()
	autoProfitExceptions = {
		"|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r", -- [1]
		"|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", -- [2]
	}
	AP.SlashCmd( "1" )
	assertEquals( 1, #autoProfitExceptions )
end
function test.test_SlashCmd_Link_AddException()
	AP.SlashCmd( "|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r" )
	assertEquals( 1, #autoProfitExceptions )
end
function test.test_SlashCmd_Link_RemoveException()
	autoProfitExceptions = {
		"|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r", -- [1]
		"|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", -- [2]
	}
	AP.SlashCmd( "|cff9d9d9d|Hitem:24580:0:0:0:0:0:0:1853764992:65:0:0|h[Loosely Threaded Hat]|h|r" )
	assertEquals( 1, #autoProfitExceptions )
	assertEquals( "|cff9d9d9d|Hitem:1501:0:0:0:0:0:0:1549255808:27:0:0|h[Calico Tunic]|h|r", autoProfitExceptions[1] )
end

function test.test_RespondsToOpenMerchant_Show()
	AP.MERCHANT_SHOW()
end


test.run()
