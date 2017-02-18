local name, XB = ...

XB.Version = "1.1"
XB.Branch  = 'Beta'
XB.Media   = 'Interface\\AddOns\\' .. name .. '\\Media\\'
XB.Color   = 'FFFFFF'

-- This exports stuff into global space
XB.Globals = {}
_G.XB = XB.Globals
