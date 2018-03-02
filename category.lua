local widget      = require("widget")
local json        = require ( "json" )
local composer    = require( "composer" )
local scene       = composer.newScene()
local offset      = display.topStatusBarContentHeight
local url         = "http://xn--04-vlcinfg0e8c.xn--p1ai/"
local topMenu     = {height=70}


function scene:create( event )
  local group = self.view
  --local sheet = graphics.newImageSheet( "resources/loading/loading2.png",{width=256,height=64,numFrames=8})
  --local sprite = display.newSprite(sheet,{start=1,count=8,time=800,loopCount=0,loopDirection="forward"})

  --///////// CART ////////////////
  local function openCart()
  end
  local buttonCart = widget.newButton(    
    {
      top = offset,
      width = 150,
      height = 70,
      id = "button1",
      label = "КОРЗИНА",
      onRelease = openCart
    })
  buttonCart.x  = display.contentWidth - buttonCart.width*0.5,
  group:insert(buttonCart)
  
  local function rowRender(event)
    local row   = event.row
    
    --title
    local title = display.newText(row, row.params.title, 20,row.height*.3,"resources/impact.ttf",row.height/2)
    title:setFillColor(.9)
    title.anchorX = 0;  title.anchorY = 0
    -- >
    local label = display.newText(row, ">",row.width,row.height*.5,nil,48)
    label:setFillColor(.5)
    label.anchorX = 1; label.anchorY = 0.5
    

    function row:touch(e)
      if e.phase == "began" then
        return true
      elseif e.phase == "moved" then
        isMoved = true
      elseif e.phase == "ended" then
        if isMoved then isMoved=nil; return true end
        local id = tonumber(self.params.id) 
        if id==1 or id==7 or id==21 then
          composer.gotoScene("subCategory",{effect="slideLeft",time=400,params={id=id}})
        else
          composer.gotoScene("products",{effect="slideLeft",time=400,params={id=id}})
        end
        return true
      end 
    end
    row:addEventListener( "touch", row )
  end 
  --

  --///////// TABLE VIEW /////////
  self.tableView = widget.newTableView{
    onRowRender = rowRender, 
    backgroundColor = {.2}, 
    top=offset+topMenu.height,
    height = display.contentHeight-(offset+topMenu.height)
  }
  group:insert(self.tableView)
  
  --/////////// get API ///////////
  local pleaseWait=display.newText(
    group,
    "Подключаюсь к серверу\nПожалуйста подождите...",
    display.contentWidth/2,
    display.contentHeight/2,
    nil,32
  )
  pleaseWait:setFillColor(.9)
  pleaseWait.anchorY = 0
  pleaseWait.alpha = 0
  transition.to( pleaseWait, { alpha = 1.0, delay=2000 } )
  
  self.getAPI = function(event)
    if ( event.isError ) then
      pleaseWait.text = "не могу подключиться\nпопробуйте позже"
      pleaseWait:setFillColor(.9,0,0)
    else
      if ( event.phase == "progress" ) then
        pleaseWait.text = "получаю данные..."
      elseif ( event.phase == "ended" ) then
        if pleaseWait.removeSelf then pleaseWait:removeSelf() end
        local myNewData = event.response
        local decodedData = ( json.decode( myNewData ) )

        for i=1,#decodedData do
            self.tableView:insertRow{
              lineColor = {0},
              rowColor  = {default={.2}},
              rowHeight = 100, 
              params    = {id=decodedData[i][1],title=decodedData[i][3]} 
            } 
        end  
        --print(string.match(decodedData[2][2], '/uploads/(.+)'))
      end
    end  
  end
end
--

function scene:show( event )
	local phase = event.phase
  if "will"== phase then
    network.request( url.."api2","POST",self.getAPI,{headers={},body="post=getCategory",progress="download"})
  end
  if "did" == phase then
    if composer.getSceneName("previous") then
      composer.removeScene(composer.getSceneName("previous"))
    end
  end
end
--
function scene:destroy( event )  
  local group = self.view
  group:removeSelf()
  group = nil  
end
--
  
scene:addEventListener( "create", scene )
scene:addEventListener( "show",   scene )
scene:addEventListener( "destroy",scene )
return scene
