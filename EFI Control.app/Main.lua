----------------------------------------core----------------------------------------
local GUI = require("GUI")
local system = require("System")
local fs = require("Filesystem")
local paths = require("Paths")
local component = require("Component")
local image = require("Image")
local EFI = component.eeprom
local pathSaveFrimware = paths.user.applicationData .. "/EFI/"
local SD = fs.path(system.getCurrentScript())
local localization = system.getLocalization(SD .. "/Localizations/")
local code = EFI.get()
local check = EFI.getChecksum()
local nameEFI = EFI.getLabel()
local bootEFI = EFI.getData()
 
local workspace, window = system.addWindow(GUI.tabbedWindow(1, 1, 118, 35, 0xF0F0F0))
local layout = window:addChild(GUI.layout(1, 3, window.width, window.height, 1, 1))

----------------------------------------func----------------------------------------
local function addButton(text)
return layout:addChild(GUI.roundedButton(1, 1, 36, 3, 0xD2D2D2, 0x696969, 0x4B4B4B, 0xF0F0F0, text))
end
 
 
local function draw()
 layout:addChild(GUI.image(1, 1, image.load(SD .. "/Icon.pic")))
 end
 
local function addText(text)
layout:addChild(GUI.text(1, 1, 0x696969, text))
end
 
local function addTab(text, func)
  window.tabBar:addItem(text).onTouch = function()
    layout:removeChildren()
    draw()
    func()
    workspace:draw()
  end
end

----------------------------------------main----------------------------------------
addTab(localization.infoEFI, function()
addText(localization.checksum .. check)
addText(localization.nameEFI .. nameEFI)
addText(localization.bootdisk .. bootEFI)
end)
 
addTab(localization.a, function()
addText(localization.saveEFIDisk)
local name = layout:addChild(GUI.input(2, 2, 30, 1, 0xD2D2D2, 0x555555, 0x999999, 0xD2D2D2, 0x2D2D2D, "", localization.filename))
addButton(localization.saveEFI).onTouch = function()
fs.write(pathSaveFrimware .. name.text ..  ".efi", code)
system.createShortcut(
  paths.user.desktop .. "EFI",
  paths.user.applicationData .. "EFI/"
)
workspace:draw()
end

addText(localization.createnameEFI)
 
 local label = layout:addChild(GUI.input(2, 2, 30, 1, 0xD2D2D2, 0x555555, 0x999999, 0xD2D2D2, 0x2D2D2D, "", localization.newNameEFI))
addButton(localization.flashNameEFI).onTouch = function()
EFI.setLabel(label.text)
end

addText(localization.flashEFI)
 
addText(localization.alert)
addButton("Flash").onTouch = function()
local frimwareChoose = layout:addChild(GUI.filesystemChooser(1, 1, 36, 1, 0xE1E1E1, 0x696969, 0xD2D2D2, 0xA5A5A5, localization.Path, localization.flash, localization.cancel, "", "/"))
  frimwareChoose:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_FILE)
  frimwareChoose:addExtensionFilter(".efi")
  frimwareChoose.onSubmit = function(path)
  local a = fs.read(path)
  EFI.set(a)
  GUI.alert(localization.successfully)
end
end
end)

addTab("About", function()
addText("This program was previously in AppMarket, but the author for some reason removed it,")
addText(" this is a release with minimal code changes (so this text is not localized).")
addText("About all bugs report to the AppMarket page or visit official github repo:")
addText("https://github.com/TheSainEyereg/EFIControl-MineOS-App")
end)

------------------------------------------------------------------------------------

window.onResize = function(width, height)
  window.tabBar.width = width
  window.backgroundPanel.width = width
  window.backgroundPanel.height = height - window.tabBar.height
  layout.width = width
  layout.height = window.backgroundPanel.height
 
  window.tabBar:getItem(window.tabBar.selectedItem).onTouch()
end
 
window:resize(window.width, window.height)




