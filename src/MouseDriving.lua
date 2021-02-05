--- ${title}

---@author ${author}
---@version r_version_r
---@date 04/02/2021

MouseDriving = {}
MouseDriving.MOD_NAME = g_currentModName

function MouseDriving.initSpecialization()
end

function MouseDriving.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function MouseDriving.registerEvents(vehicleType)
end

function MouseDriving.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "toggleMouseDriving", MouseDriving.toggleMouseDriving)
end

function MouseDriving.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", MouseDriving)
end

function MouseDriving:onPreLoad(savegame)
    ---@type table
    self.spec_mouseDriving = self[string.format("spec_%s.mouseDriving", MouseDriving.MOD_NAME)]
    local spec = self.spec_mouseDriving
    spec.enabled = false
    spec.lastMousePosX = 0.5
    spec.lastMousePosY = 0.5

    MouseDrivingMain:addMouseEventListener(self, MouseDriving.onMouseDrivingEvent)
end

function MouseDriving:onDelete()
    MouseDrivingMain:removeMouseEventListener(self)
end

function MouseDriving:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if self:getIsEntered() then
        local spec = self.spec_mouseDriving
        renderText(0.5, 0.5, 0.02, string.format("%s %s", spec.lastMousePosX, spec.lastMousePosY))
    end
end

function MouseDriving:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self.spec_mouseDriving
    if self:getIsEntered() then
        self:clearActionEventsTable(spec.actionEvents)
        if self:getIsActiveForInput(true, true) then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_TOGGLE, self, MouseDriving.onToggleMouseDriving, false, true, false, true, nil, nil, true)
            g_inputBinding:setActionEventTextVisibility(actionEventId, false)
        end
    end
end

function MouseDriving:toggleMouseDriving(enabled)
    local spec = self.spec_mouseDriving
    spec.enabled = enabled
end

function MouseDriving.onToggleMouseDriving(self, actionName, inputValue, callbackState, isAnalog, isMouse)
    local spec = self.spec_mouseDriving
    self:toggleMouseDriving(not spec.enabled)
    DebugUtil.printTableRecursively(g_inputBinding, nil, nil, 0)
end

function MouseDriving.onMouseDrivingEvent(self, x, y)
    if self:getIsEntered() then
        local spec = self.spec_mouseDriving
        if spec.enabled then
            if x ~= 0.5 then
                spec.lastMousePosX = x
            end
            if y ~= 0.5 then
                spec.lastMousePosY = y
            end
        end
    end
end
