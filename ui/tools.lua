local _, XB          = ...
local usedGUIs        = {}
XB.Interface         = {}
XB.Globals.Interface = {}

-- Locals
local LibStub     = LibStub
local strupper    = strupper
local DiesalGUI   = LibStub("DiesalGUI-1.0")
local DiesalTools = LibStub("DiesalTools-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

function XB.Interface:Header(element, parent, offset, table)
    local tmp = DiesalGUI:Create("FontString")
    tmp:SetParent(parent.content)
    parent:AddChild(tmp)
    tmp = tmp.fontString
    tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
    tmp:SetText('|cff'..table.color..element.text)
    if element.justify then
        tmp:SetJustifyH(element.justify)
    else
        tmp:SetJustifyH('LEFT')
    end
    tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
    tmp:SetWidth(parent.content:GetWidth()-10)
    if element.align then
        tmp:SetJustifyH(strupper(element.align))
    end
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Text(element, parent, offset, table)
    local tmp = DiesalGUI:Create("FontString")
    tmp:SetParent(parent.content)
    parent:AddChild(tmp)
    tmp = tmp.fontString
    tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
    tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
    tmp:SetText(element.text)
    tmp:SetJustifyH('LEFT')
    tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), element.size or 10)
    tmp:SetWidth(parent.content:GetWidth()-10)
    if not element.offset then
        element.offset = tmp:GetStringHeight()
    end
    if element.align then
        tmp:SetJustifyH(strupper(element.align))
    end
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Rule(element, parent, offset, table)
    local tmp = DiesalGUI:Create('Rule')
    parent:AddChild(tmp)
    tmp:SetParent(parent.content)
    tmp.frame:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5, offset-3)
    tmp.frame:SetPoint('BOTTOMRIGHT', parent.content, 'BOTTOMRIGHT', -5, offset-3)
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Texture(element, parent, offset, table)
    local tmp = CreateFrame('Frame')
    tmp:SetParent(parent.content)
    if element.center then
        tmp:SetPoint('CENTER', parent.content, 'CENTER', (element.x or 0), offset-(element.y or 0))
    else
        tmp:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5+(element.x or 0), offset-3+(element.y or 0))
    end
    tmp:SetWidth(parent:GetWidth()-10)
    tmp:SetHeight(element.height)
    tmp:SetWidth(element.width)
    tmp.texture = tmp:CreateTexture()
    tmp.texture:SetTexture(element.texture)
    tmp.texture:SetAllPoints(tmp)
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Checkbox(element, parent, offset, table)
    local tmp = DiesalGUI:Create('CheckBox')
    parent:AddChild(tmp)
    tmp:SetParent(parent.content)
    tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-2)
    tmp:SetEventListener('OnValueChanged', function(_, _, checked)
        XB.Config:Write(table.key, element.key, checked)
    end)
    tmp:SetChecked(XB.Config:Read(table.key, element.key, element.default or false))
    XB.Config:Write(table.key, element.key, XB.Config:Read(table.key, element.key, element.default or false))
    local tmp_text = DiesalGUI:Create("FontString")
    tmp_text:SetParent(parent.content)
    parent:AddChild(tmp_text)
    tmp_text = tmp_text.fontString
    tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 20, offset-1)
    tmp_text:SetText(element.text)
    tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-15)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-15)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.key then
        usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Spinner(element, parent, offset, table)
    local tmp_spin = DiesalGUI:Create('Spinner')
    parent:AddChild(tmp_spin)
    tmp_spin:SetParent(parent.content)
    tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-1)
    tmp_spin:SetNumber(
        XB.Config:Read(table.key, element.key, element.default)
    )
    XB.Config:Write(table.key, element.key, XB.Config:Read(table.key, element.key, element.default))
    if element.width then
        tmp_spin.settings.width = element.width
    end
    if element.min then
        tmp_spin.settings.min = element.min
    end
    if element.max then
        tmp_spin.settings.max = element.max
    end
    if element.step then
        tmp_spin.settings.step = element.step
    end
    if element.shiXBtep then
        tmp_spin.settings.shiXBtep = element.shiXBtep
    end
    tmp_spin:ApplySettings()
    tmp_spin:AddStyleSheet(XB.UI.spinnerStyleSheet)
    tmp_spin:SetEventListener('OnValueChanged', function(_, _, userInput, number)
        if not userInput then return end
        XB.Config:Write(table.key, element.key, number)
        if element.callback then element.callback(number) end
    end)
    local tmp_text = DiesalGUI:Create("FontString")
    tmp_text:SetParent(parent.content)
    parent:AddChild(tmp_text)
    tmp_text = tmp_text.fontString
    tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 20, offset-4)
    tmp_text:SetText(element.text)
    tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
    tmp_text:SetJustifyH('LEFT')
    tmp_text:SetWidth(parent.content:GetWidth()-10)
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.key then
        usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
        usedGUIs[table.key].elements[element.key] = tmp_spin
    end
end

function XB.Interface:Checkspin(element, parent, offset, table)
    local tmp_spin = DiesalGUI:Create('Spinner')
    parent:AddChild(tmp_spin)
    tmp_spin:SetParent(parent.content)
    tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-1)
    if element.width then
        tmp_spin.settings.width = element.width
    end
    if element.min then
        tmp_spin.settings.min = element.min
    end
    if element.max then
        tmp_spin.settings.max = element.max
    end
    if element.step then
        tmp_spin.settings.step = element.step
    end
    if element.shiXBtep then
        tmp_spin.settings.shiXBtep = element.shiXBtep
    end
    tmp_spin:SetNumber(
        XB.Config:Read(table.key, element.key..'_spin', element.default_spin or 0)
    )
    XB.Config:Write(table.key, element.key..'_spin', XB.Config:Read(table.key, element.key..'_spin', element.default_spin or 0))
    tmp_spin:AddStyleSheet(XB.UI.spinnerStyleSheet)
    tmp_spin:ApplySettings()
    tmp_spin:SetEventListener('OnValueChanged', function(_, _, userInput, number)
        if not userInput then return end
        XB.Config:Write(table.key, element.key..'_spin', number)
    end)
    local tmp_check = DiesalGUI:Create('CheckBox')
    parent:AddChild(tmp_check)
    tmp_check:SetParent(parent.content)
    tmp_check:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-4)
    tmp_check:SetEventListener('OnValueChanged', function(_, _, checked)
        XB.Config:Write(table.key, element.key..'_check', checked)
    end)
    tmp_check:SetChecked(XB.Config:Read(table.key, element.key..'_check', element.default_check or false))
    XB.Config:Write(table.key, element.key..'_check', XB.Config:Read(table.key, element.key..'_check', element.default_check or false))
    local tmp_text = DiesalGUI:Create("FontString")
    tmp_text:SetParent(parent.content)
    parent:AddChild(tmp_text)
    tmp_text = tmp_text.fontString
    tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 20, offset-4)
    tmp_text:SetText(element.text)
    tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
    tmp_text:SetJustifyH('LEFT')
    tmp_text:SetWidth(parent.content:GetWidth()-10)
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.key then
        usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
        usedGUIs[table.key].elements[element.key..'Check'] = tmp_check
        usedGUIs[table.key].elements[element.key..'Spin'] = tmp_spin
    end
end

function XB.Interface:Combo(element, parent, offset, table)
    local tmp_list = DiesalGUI:Create('Dropdown')
    parent:AddChild(tmp_list)
    tmp_list:SetParent(parent.content)
    tmp_list:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
    local orderdKeys = { }
    local list = { }
    for i, value in pairs(element.list) do
        orderdKeys[i] = value.key
        list[value.key] = value.text
    end
    tmp_list:SetList(list, orderdKeys)
    tmp_list:SetEventListener('OnValueChanged', function(_, _, value)
        XB.Config:Write(table.key, element.key, value)
    end)
    tmp_list:SetValue(XB.Config:Read(table.key, element.key, element.default))
    XB.Config:Write(table.key, element.key, XB.Config:Read(table.key, element.key, element.default))
    local tmp_text = DiesalGUI:Create("FontString")
    tmp_text:SetParent(parent.content)
    parent:AddChild(tmp_text)
    tmp_text = tmp_text.fontString
    tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-3)
    tmp_text:SetText(element.text)
    tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
    tmp_text:SetJustifyH('LEFT')
    tmp_text:SetWidth(parent.content:GetWidth()-10)
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.key then
        usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
        usedGUIs[table.key].elements[element.key] = tmp_list
    end
end

function XB.Interface:Button(element, parent, offset, table)
    local tmp = DiesalGUI:Create("Button")
    parent:AddChild(tmp)
    tmp:SetParent(parent.content)
    tmp:SetText(element.text)
    tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 12)
    tmp:SetWidth(element.width or 100)
    tmp:SetHeight(element.height or 20)
    tmp:AddStyleSheet(XB.UI.buttonStyleSheet)
    tmp:SetEventListener("OnClick", element.callback)
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-element.height-3)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-element.height-3)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.align then
        local loc = element.align
        tmp:SetPoint(loc, parent.content, 0, offset)
    else
        tmp:SetPoint("TOPLEFT", parent.content, 0, offset)
    end
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp
    end
end

function XB.Interface:Input(element, parent, offset, table)
    local tmp_input = DiesalGUI:Create('Input')
    parent:AddChild(tmp_input)
    tmp_input:SetParent(parent.content)
    tmp_input:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
    if element.width then
        tmp_input:SetWidth(element.width)
    end
    tmp_input:SetText(XB.Config:Read(table.key, element.key, element.default or ''))
    XB.Config:Write(table.key, element.key, XB.Config:Read(table.key, element.key, element.default or ''))
    tmp_input:SetEventListener('OnEditFocusLost', function(this)
        XB.Config:Write(table.key, element.key, this:GetText())
    end)
    local tmp_text = DiesalGUI:Create("FontString")
    tmp_text:SetParent(parent.content)
    parent:AddChild(tmp_text)
    tmp_text = tmp_text.fontString
    tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-3)
    tmp_text:SetText(element.text)
    tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
    tmp_text:SetJustifyH('LEFT')
    if element.desc then
        local tmp_desc = DiesalGUI:Create("FontString")
        tmp_desc:SetParent(parent.content)
        parent:AddChild(tmp_desc)
        tmp_desc = tmp_desc.fontString
        tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
        tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
        tmp_desc:SetText(element.desc)
        tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
        tmp_desc:SetWidth(parent.content:GetWidth()-10)
        tmp_desc:SetJustifyH('LEFT')
        element.push = tmp_desc:GetStringHeight() + 5
    end
    if element.key then
        usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
        usedGUIs[table.key].elements[element.key] = tmp_input
    end
end

function XB.Interface:Statusbar(element, parent, _, table)
    local tmp_statusbar = DiesalGUI:Create('StatusBar')
    parent:AddChild(tmp_statusbar)
    tmp_statusbar:SetParent(parent.content)
    tmp_statusbar.frame:SetStatusBarColor(DiesalTools:GetColor(element.color))
    if element.value then
        tmp_statusbar:SetValue(element.value)
    end
    if element.textLeft then
        tmp_statusbar.frame.Left:SetText(element.textLeft)
    end
    if element.textRight then
        tmp_statusbar.frame.Right:SetText(element.textRight)
    end
    if element.key then
        usedGUIs[table.key].elements[element.key] = tmp_statusbar
    end
end

function XB.Interface:Noop() end

local _Elements = {
    header      = { func = 'Header', offset = -16 },
    text        = { func = 'Text', offset = 0 },
    rule        = { func = 'Rule', offset = -10 },
    ruler       = { func = 'Rule', offset = -10 },
    texture     = { func = 'Texture', offset = 0 },
    checkbox    = { func = 'Checkbox', offset = -16 },
    spinner     = { func = 'Spinner', offset = -19 },
    checkspin   = { func = 'Checkspin', offset = -19 },
    combo       = { func = 'Combo', offset = -20 },
    dropdown    = { func = 'Combo', offset = -20 },
    button      = { func = 'Button', offset = -20 },
    input       = { func = 'Input', offset = -16 },
    spacer      = { func = 'Noop', offset = -10 },
}

function XB.Interface:BuildElements(table, parent)
    local offset = -5
    usedGUIs[table.key].elements = {}
    for _, element in ipairs(table.config) do
        local push, pull = 0, 0
        -- Create defaults
        if element.key and not XB.Config:Read(table.key, element.key) then
            if element.default then
                XB.Config:Write(table.key, element.key, element.default)
            elseif element.default_check then
                XB.Config:Write(table.key, element.key, element.default_check)
                XB.Config:Write(table.key, element.key, element.default_Spin)
            end
        end
        if _Elements[element.type] then
            local func = _Elements[element.type].func
            local _offset = _Elements[element.type].offset
            self[func](self, element, parent, offset, table)
            offset = offset + _offset
        end
        if element.type == 'texture' then
            offset = offset + -(element.offset or 0)
        elseif element.type == "text" then
            offset = offset + -(element.offset) - (element.size or 10)
        end
    if element.push then
      push = push + element.push
      offset = offset + -(push)
    end
    if element.pull then
      pull = pull + element.pull
      offset = offset + pull
    end
    end
end

function XB.Interface:GetElement(key, element)
    return usedGUIs[key].elements[element]
end

function XB.Interface:BuildGUI(eval)
    -- This opens a existing GUI instead of creating another
    local test = type(eval) == 'string' and eval or eval.key
    if usedGUIs[test] then
        usedGUIs[test].parent:Show()
        return
    end
    -- Create a new one
    if not eval.key then return end
    usedGUIs[eval.key] = {}
    local parent = DiesalGUI:Create('Window')
    usedGUIs[eval.key].parent = parent
    parent:SetWidth(eval.width or 200)
    parent:SetHeight(eval.height or 300)
    parent:SetTitleFont(SharedMedia:Fetch('font', 'Fira Sans'), 11)
    parent.frame:SetClampedToScreen(true)
    parent:SetEventListener('OnDragStop', function(self, _, left, top)
        XB.Config:Write(eval.key, 'Location', {left, top})
    end)
    XB.Core:WhenInGame(function()
        local left, top = unpack(XB.Config:Read(eval.key, 'Location', {500, 500}))
        parent.settings.left = left
        parent.settings.top = top
        parent:UpdatePosition()
        if not eval.color then eval.color = XB.Color end
        if type(eval.color) == 'function' then eval.color = eval.color() end
        -- XB.UI.spinnerStyleSheet['bar-background']['color'] = eval.color
        if eval.title then
            parent:SetTitle("|cff"..eval.color..eval.title.."|r", eval.subtitle)
        end
        if eval.config then
            local window = DiesalGUI:Create('ScrollFrame')
            parent:AddChild(window)
            window:SetParent(parent.content)
            window:SetAllPoints(parent.content)
            window.elements = { }
            eval.window = window
            XB.Interface:BuildElements(eval, window)
        end
    end)
    return parent
end

-- Gobals
XB.Globals.Interface = {
    BuildGUI = XB.Interface.BuildGUI,
    Fetch = XB.Config.Read,
    GetElement = XB.Interface.GetElement
}
