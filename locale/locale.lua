local _, XB = ...

XB.Locale = {}

local locale = GetLocale()
function XB.Locale:TA(gui, index)
  if XB.Locale[locale] and XB.Locale[locale][gui] then
    if XB.Locale[locale][gui][index] then
      return XB.Locale[locale][gui][index]
    end
  end
  return XB.Locale.zhCN[gui][index] or 'INVALID STRING'
end