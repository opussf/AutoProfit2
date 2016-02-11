#!/usr/bin/env lua

addonData = { ["version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "AutoProfit"

function test.before()
end

function test.after()
end

--[[
Test Plan:

Overview:
This addon fires only when a merchant window opens, and sells grey items.



Setup:



]]

function test.test_RespondsToOpenMerchant_Show()
	AP.MERCHANT_SHOW()
end

test.run()
