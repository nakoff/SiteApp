local widget      = require("widget")
local composer    = require( "composer" )
local wrap        = require("resources.wrap")
local scene       = composer.newScene()
local offset      = display.topStatusBarContentHeight
local url         = "http://xn--04-vlcinfg0e8c.xn--p1ai/"

function scene:show( event )
	local phase = event.phase
  if "will"== phase then
    local group = self.view
    local parent = event.parent
    globalEvent.parent  = parent
  
    --background
    local bg=display.newRect(group,5,display.contentHeight*0.5,display.contentWidth-10,display.contentHeight*0.5)
    bg:setFillColor(0.85)
    bg.anchorX = 0
    bg.alpha = 0.9
  
    --image
    local image = display.loadRemoteImage( 
      url.."uploads/product/"..event.params.prodId.."/"..event.params.id.."/thumbs/70_"..parent.params[event.params.id].url, 
      "GET", 
      function(e)
        if e == nil then return end
          if e.target  then
            if bg == nil then return end
            e.target.anchorX = 0.5
            e.target.anchorY = 1
            e.target.x = display.contentWidth*0.5
            e.target.y = display.contentHeight*0.5
            e.target.alpha = 0
            transition.to( e.target, { alpha = 1.0 } )
            if group.insert then group:insert(e.target)
            else e.target:removeSelf() end
          end
      end,
      "70"..parent.params[event.params.id].url, 
      system.TemporaryDirectory
    )

    --description
    local txt = string.match(parent.params[event.params.id].desc, '<p>(.+)</p>')
    if txt == nil then txt = parent.params[event.params.id].desc end
    local textWrapp = wrap:newParagraph({
      text = txt,
      width = bg.width-20,
      height = bg.height-10,
      fontSize = 32,
      lineSpace = 2,
      alignment  = "center",

      fontSizeMin = 12,
      fontSizeMax = 48,
      incrementSize = 2
    })
    textWrapp.anchorChildren = true
    textWrapp.anchorX = 0.5
    textWrapp.anchorY = 0
    textWrapp.x = bg.width*0.5
    textWrapp.y = 315+bg.y-bg.height*0.5
    textWrapp:setTextColor({0})
    group:insert(textWrapp)
    
    --close button
    local function close() 
      composer.hideOverlay( "crossFade", 400 ) 
      composer.removeScene("product")
    end
    local buttonClose = widget.newButton(    
      {
        x         = 10,
        y         = bg.y+bg.height*0.5,
        height    = 70,
        id        = "button1",
        label     = "ЗАКРЫТЬ",
        onRelease = close
      })
    buttonClose.anchorX = 0
    buttonClose.anchorY = 0
    group:insert(buttonClose)
    
    local function addCart() 
      globalCart[event.params.id]       = {}
      globalCart[event.params.id].url   = parent.params[event.params.id].url
      globalCart[event.params.id].title = parent.params[event.params.id].title
      globalCart[event.params.id].price = parent.params[event.params.id].price
      
      composer.hideOverlay( "crossFade", 400 ) 
      composer.removeScene("product")
    end
    local buttonCart = widget.newButton(    
      {
        x         = bg.width -10,
        y         = bg.y+bg.height*0.5,
        height    = 70,
        id        = "button2",
        label     = "В КОРЗИНУ",
        onRelease = addCart
      })
    buttonCart.anchorX = 1
    buttonCart.anchorY = 0
    buttonCart.labelColor ={default={0,1,0},over={0,1,1}}
    group:insert(buttonCart)
  end
  if "did" == phase then
  end
end
--
function scene:destroy( event ) 
  local group = self.view
  group:removeSelf()
  globalEvent.parent = nil
  group = nil
end
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )
return scene
