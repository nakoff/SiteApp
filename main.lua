local composer  = require "composer"
local widget    = require("widget")
display.setStatusBar(display.DefaultStatusBar)

_G.globalCart   = {   }    
_G.globalEvent  = {   }

local function onKeyEvent( e ) 
  if ( e.keyName=="back" and e.phase=="up" ) then
    if globalEvent.parent then
      composer.hideOverlay()
    else
      if  (composer.getSceneName("current")=="category") then
        native.requestExit()
      elseif  (composer.getSceneName("current") == "subCategory") then
        composer.gotoScene("category",{effect="slideRight",time=400})
      elseif  (composer.getSceneName("current") == "products") then
        composer.gotoScene(
          composer.getSceneName("previous"),
          {effect="slideRight",time=400, params={id=globalEvent.id}}
        )
      end
    end
    return true
  end
  return false
end
Runtime:addEventListener( "key", onKeyEvent )

composer.gotoScene( "category", "fade", 400 )

