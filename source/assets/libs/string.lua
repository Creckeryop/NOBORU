utf8L =
{
	["а"] = "А",
	["б"] = "Б",
	["в"] = "В",
	["г"] = "Г",
	["д"] = "Д",
	["е"] = "Е",
	["ё"] = "Ё",
	["ж"] = "Ж",
	["з"] = "З",
	["и"] = "И",
	["й"] = "Й",
	["к"] = "К",
	["л"] = "Л",
	["м"] = "М",
	["н"] = "Н",
	["о"] = "О",
	["п"] = "П",
	["р"] = "Р",
	["с"] = "С",
	["т"] = "Т",
	["у"] = "У",
	["ф"] = "Ф",
	["х"] = "Х",
	["ц"] = "Ц",
	["ч"] = "Ч",
	["ш"] = "Ш",
	["щ"] = "Щ",
	["ъ"] = "Ъ",
	["ы"] = "Ы",
	["ь"] = "Ь",
	["э"] = "Э",
	["ю"] = "Ю",
	["я"] = "Я"
}
utf8U =
{
	["А"] = "а",
	["Б"] = "б",
	["В"] = "в",
	["Г"] = "г",
	["Д"] = "д",
	["Е"] = "е",
	["Ё"] = "ё",
	["Ж"] = "ж",
	["З"] = "з",
	["И"] = "и",
	["Й"] = "й",
	["К"] = "к",
	["Л"] = "л",
	["М"] = "м",
	["Н"] = "н",
	["О"] = "о",
	["П"] = "п",
	["Р"] = "р",
	["С"] = "с",
	["Т"] = "т",
	["У"] = "у",
	["Ф"] = "ф",
	["Х"] = "х",
	["Ц"] = "ц",
	["Ч"] = "ч",
	["Ш"] = "ш",
	["Щ"] = "щ",
	["Ъ"] = "ъ",
	["Ы"] = "ы",
	["Ь"] = "ь",
	["Э"] = "э",
	["Ю"] = "ю",
	["Я"] = "я"
}
function it_utf8(str)
	return string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)")
end
local old_lower = string.lower
function string:lower()
	local str = ""
	for c in it_utf8(self) do
		if utf8U[c]==nil then
			str = str .. old_lower(c)
		else
			str = str .. utf8U[c]
		end
	end
	return str
end
local old_upper = string.upper
function string:upper()
	local str = ""
	for c in it_utf8(self) do
		if utf8L[c]==nil then
			str = str .. old_upper(c)
		else
			str = str..utf8L[c]
		end
	end
	return str
end
function string:sub(i,k)
	k = k or -1
	local text = ""
	for c in it_utf8(self) do
		if i==1 then
			if k~=0 then
				text = text..c
				k = k - 1
			else
				break
			end
		else
			i = i - 1
		end
	end
	return text
end
function string:len()
	return select(2,string.gsub(self, "[^\128-\193]", ""))
end