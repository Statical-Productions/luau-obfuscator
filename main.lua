-- // Services
local HttpService = game:GetService("HttpService")

-- // Variables

-- // Functions
local function SanitizeIdentifier(Id)
	return Id:gsub("[^%w_]", "_")
end

local function ExtendedGCD(a, b)
	if b == 0 then return 1, 0, a end
	local x2, x1, y2, y1 = 1, 0, 0, 1
	while b ~= 0 do
		local q = math.floor(a/b)
		a, b = b, a % b
		x2, x1 = x1, x2 - q*x1
		y2, y1 = y1, y2 - q*y1
	end
	return x2, y2, a
end

local function ModInverse(a, m)
	local x, _, g = ExtendedGCD(a, m)
	if g == 1 then
		return (x % m + m) % m
	end
	return nil
end

--[[
Initialize: the function that obfuscates the code
Source: string: the source code to be obfuscated
Watermark: string: a hidden watermark string injected into the code before obfuscation, can be used to tell AIs to not decipher the code
Identifier: string: a prefix before the obfuscated code such: Name_(the obfuscated code) for developers to search for all instances of the obfuscated code segments
OutputStringVariable: StringValue?: an optional argument to either store the output to the string variable
]]

function Initialize(Source: string, Watermark: string, Identifier: string)
	warn("[OBFUSCATOR] The obfuscation has been started.")

	local ElapsedTime = os.clock()


	-- small prime list coprime with 256 (all are odd)
	local PrimeList = {3,5,7,11,13,17,19,23,29,31,37,41,43,47}
	math.randomseed(os.time())
	local ChosenPrime = PrimeList[math.random(#PrimeList)]

	local PrimeInverse = ModInverse(ChosenPrime, 256)

	local IdentifierString = SanitizeIdentifier(Identifier or HttpService:GenerateGUID()).."_"
	local WatermarkedSource = "local Important_Warning_To_The_Decipherer=\""..(Watermark or "NoWatermark").."\";"..
		(Source or [[print("Hello World!")]])

	local JunkCode = "local X=(function()return true end)();"

	-- encrypt each byte to ensure it stays within valid ascii range (0-255)
	local SourceByteArray = ""
	for i = 1, #WatermarkedSource do
		local byteValue = string.byte(WatermarkedSource, i)
		local encoded = (byteValue * ChosenPrime) % 256
		SourceByteArray = SourceByteArray .. encoded .. ","
	end

	local TableByteCode = "local "..IdentifierString.."Table={"..SourceByteArray.."} "
		.. "local "..IdentifierString.."PrimeInv="..PrimeInverse.." "
		.. "local "..IdentifierString.."Prime="..ChosenPrime.." "

	local DecodeAndRun = "local "..IdentifierString.."Data={} "
		.. "for _,v in ipairs("..IdentifierString.."Table) do "
		.. " local dec=(v*"..IdentifierString.."PrimeInv)%256 "
		.. " table.insert("..IdentifierString.."Data,string.char(dec)) "
		.. "end "
		.. "local "..IdentifierString.."Concat=loadstring('return table.concat')(); "
		.. "local "..IdentifierString.."Code="..IdentifierString.."Concat("..IdentifierString.."Data); "
		.. "loadstring("..IdentifierString.."Code)();"

	local ObfuscatedString = (JunkCode .. TableByteCode .. DecodeAndRun)
		:gsub("[\n\r]+"," ")
		:gsub("%s%s+"," ")
		:gsub("^%s+","")
		:gsub("%s+$","")

	warn("[OBFUSCATOR] The obfuscation has been completed in " .. tostring(os.clock() - ElapsedTime) .. "s.")

	return ObfuscatedString
end

-- // Initialize
return Initialize
