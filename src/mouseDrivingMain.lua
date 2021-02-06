--- ${title}

---@author ${author}
---@version r_version_r
---@date 04/02/2021

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("utility/", g_currentModDirectory))
InitRoyalSettings(Utils.getFilename("rset/", g_currentModDirectory))
InitRoyalHud(Utils.getFilename("hud/", g_currentModDirectory))

---@class MouseDrivingMain : RoyalMod
MouseDrivingMain = RoyalMod.new(r_debug_r, false)
MouseDrivingMain.settingsChangeListeners = {}
MouseDrivingMain.fillLevelsDisplay = nil
MouseDrivingMain.showHud = true
MouseDrivingMain.axes = {}
MouseDrivingMain.axes.x = 0
MouseDrivingMain.axes.y = 0
MouseDrivingMain.axes.invertY = -1

function MouseDrivingMain:initialize()
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookLeftRight", MouseDrivingMain.VehicleCamera_actionEventLookLeftRight)
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookUpDown", MouseDrivingMain.VehicleCamera_actionEventLookUpDown)
    Utility.overwrittenStaticFunction(FillLevelsDisplay, "new", MouseDrivingMain.FillLevelsDisplay_new)
end

function MouseDrivingMain:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
    addSpecializationBySpecialization("mouseDriving", "drivable")
end

function MouseDrivingMain:onMissionInitialize(baseDirectory, missionCollaborators)
end

function MouseDrivingMain:onSetMissionInfo(missionInfo, missionDynamicInfo)
end

function MouseDrivingMain:onLoad()
    g_royalSettings:registerMod(self.name, self.directory .. "settings_icon.dds", "$l10n_md_mod_settings_title")

    g_royalSettings:registerSetting(
        self.name,
        "deadZone",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        4,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_deadZone",
        "$l10n_md_setting_deadZone_tooltip"
    ):addCallback(self.onDeadZoneChange, self)

    g_royalSettings:registerSetting(
        self.name,
        "sensitivity",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        4,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_sensitivity",
        "$l10n_md_setting_sensitivity_tooltip"
    ):addCallback(self.onSensitivityChange, self)

    g_royalSettings:registerSetting(self.name, "hud", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 1, {true, false}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_md_setting_hud", "$l10n_md_setting_hud_tooltip"):addCallback(
        self.onHudChange,
        self
    )

    g_royalSettings:registerSetting(self.name, "invert_throttle", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 2, {1, -1}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_md_setting_hud", "$l10n_md_setting_hud_tooltip"):addCallback(
        self.onInvertThrottleChange,
        self
    )
end

function MouseDrivingMain:onDeadZoneChange(value)
    for object, event in pairs(MouseDrivingMain.settingsChangeListeners) do
        event(object, value, nil)
    end
end

function MouseDrivingMain:onSensitivityChange(value)
    for object, event in pairs(MouseDrivingMain.settingsChangeListeners) do
        event(object, nil, value)
    end
end

function MouseDrivingMain:onHudChange(value)
    MouseDrivingMain.showHud = value
end

function MouseDrivingMain:onInvertThrottleChange(value)
    MouseDrivingMain.axes.invertY = value
end

function MouseDrivingMain:onPreLoadMap(mapFile)
end

function MouseDrivingMain:onCreateStartPoint(startPointNode)
end

function MouseDrivingMain:onLoadMap(mapNode, mapFile)
end

function MouseDrivingMain:onPostLoadMap(mapNode, mapFile)
end

function MouseDrivingMain:onLoadSavegame(savegameDirectory, savegameIndex)
end

function MouseDrivingMain:onPreLoadVehicles(xmlFile, resetVehicles)
end

function MouseDrivingMain:onPreLoadItems(xmlFile)
end

function MouseDrivingMain:onPreLoadOnCreateLoadedObjects(xmlFile)
end

function MouseDrivingMain:onLoadFinished()
end

function MouseDrivingMain:onStartMission()
end

function MouseDrivingMain:onMissionStarted()
end

function MouseDrivingMain:onWriteStream(streamId)
end

function MouseDrivingMain:onReadStream(streamId)
end

function MouseDrivingMain:onUpdate(dt)
    --Utility.renderTable(0.2, 0.8, 0.02, self.axes)
end

function MouseDrivingMain:onUpdateTick(dt)
end

function MouseDrivingMain:onWriteUpdateStream(streamId, connection, dirtyMask)
end

function MouseDrivingMain:onReadUpdateStream(streamId, timestamp, connection)
end

function MouseDrivingMain:onMouseEvent(posX, posY, isDown, isUp, button)
end

function MouseDrivingMain:onKeyEvent(unicode, sym, modifier, isDown)
end

function MouseDrivingMain:onDraw()
end

function MouseDrivingMain:onPreSaveSavegame(savegameDirectory, savegameIndex)
end

function MouseDrivingMain:onPostSaveSavegame(savegameDirectory, savegameIndex)
end

function MouseDrivingMain:onPreDeleteMap()
end

function MouseDrivingMain:onDeleteMap()
end

function MouseDrivingMain:onLoadHelpLine()
    --return self.directory .. "gui/helpLine.xml"
end

function MouseDrivingMain.VehicleCamera_actionEventLookUpDown(superFunc, camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    if not isMouse or camera == nil or camera.vehicle == nil or camera.vehicle.spec_mouseDriving == nil or not camera.vehicle.spec_mouseDriving.enabled then
        superFunc(camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    end
    if isMouse then
        MouseDrivingMain.axes.y = inputValue * MouseDrivingMain.axes.invertY
    end
end

function MouseDrivingMain.VehicleCamera_actionEventLookLeftRight(superFunc, camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    if not isMouse or camera == nil or camera.vehicle == nil or camera.vehicle.spec_mouseDriving == nil or not camera.vehicle.spec_mouseDriving.enabled then
        superFunc(camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    end
    if isMouse then
        MouseDrivingMain.axes.x = inputValue
    end
end

function MouseDrivingMain.FillLevelsDisplay_new(superFunc, hudAtlasPath)
    local instance = superFunc(hudAtlasPath)
    MouseDrivingMain.fillLevelsDisplay = instance
    return instance
end

---@param object table
---@param event function
function MouseDrivingMain:addSettingsChangeListener(object, event)
    MouseDrivingMain.settingsChangeListeners[object] = event
end

---@param object table
function MouseDrivingMain:removeSettingsChangeListener(object)
    MouseDrivingMain.settingsChangeListeners[object] = nil
end
