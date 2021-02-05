--- ${title}

---@author ${author}
---@version r_version_r
---@date 04/02/2021

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("utility/", g_currentModDirectory))

---@class MouseDrivingMain : RoyalMod
MouseDrivingMain = RoyalMod.new(r_debug_r, false)
MouseDrivingMain.mouseEventListeners = {}

function MouseDrivingMain:initialize()
end

function MouseDrivingMain:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
    addSpecializationBySpecialization("mouseDriving", "drivable")
end

function MouseDrivingMain:onMissionInitialize(baseDirectory, missionCollaborators)
end

function MouseDrivingMain:onSetMissionInfo(missionInfo, missionDynamicInfo)
end

function MouseDrivingMain:onLoad()
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookLeftRight", MouseDrivingMain.VehicleCamera_actionEventLookLeftRight)
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookUpDown", MouseDrivingMain.VehicleCamera_actionEventLookUpDown)
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
end

function MouseDrivingMain:onUpdateTick(dt)
end

function MouseDrivingMain:onWriteUpdateStream(streamId, connection, dirtyMask)
end

function MouseDrivingMain:onReadUpdateStream(streamId, timestamp, connection)
end

function MouseDrivingMain:onMouseEvent(posX, posY, isDown, isUp, button)
    for object, event in pairs(MouseDrivingMain.mouseEventListeners) do
        event(object, posX, posY)
    end
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
end

function MouseDrivingMain.VehicleCamera_actionEventLookLeftRight(superFunc, camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    if not isMouse or camera == nil or camera.vehicle == nil or camera.vehicle.spec_mouseDriving == nil or not camera.vehicle.spec_mouseDriving.enabled then
        superFunc(camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    end
end

---@param object table
---@param event function
function MouseDrivingMain:addMouseEventListener(object, event)
    MouseDrivingMain.mouseEventListeners[object] = event
end

---@param object table
function MouseDrivingMain:removeMouseEventListener(object)
    MouseDrivingMain.mouseEventListeners[object] = nil
end
