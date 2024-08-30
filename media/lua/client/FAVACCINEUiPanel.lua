--- Define a custom panel for displaying vaccine information
VaccineInfoPanel = ISCollapsableWindow:derive("VaccineInfoPanel")

function VaccineInfoPanel:initialise()
    ISCollapsableWindow.initialise(self)
end

function VaccineInfoPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- Create a panel for text
    self.textPanel = ISPanel:new(10, 30, self.width - 20, self.height - 40)
    self.textPanel:initialise()
    self.textPanel:setAnchorRight(true)
    self.textPanel:setAnchorBottom(true)
    self:addChild(self.textPanel)

    -- Create a label for displaying text
    self.textLabel = ISLabel:new(15, 40, 18, "", 1, 1, 1, 1, UIFont.Small, true)
    self.textLabel:initialise()
    self.textPanel:addChild(self.textLabel)
end

function VaccineInfoPanel:render()
    ISCollapsableWindow.render(self)

    -- Update text based on vaccine information
    self.textLabel:setName(self.vaccineInfo)
end

function VaccineInfoPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Vaccine Information"
    o.vaccineInfo = ""
    return o
end
