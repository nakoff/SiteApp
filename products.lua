local widget      = require("widget")
local json        = require ( "json" )
local composer    = require( "composer" )
local wrap        = require("resources.wrap")
local url         = "http://xn--04-vlcinfg0e8c.xn--p1ai/"
local offset      = display.topStatusBarContentHeight
local scene       = composer.newScene()
local topMenu     = {height=70}
--
function scene:create( event )
  local group = self.view
  self.params = {}
  
  --///////// CART ////////////////
  local function openCart()
    composer.showOverlay( "cart", {isModal=true,effect = "fromTop",time=400} )
  end
  local buttonCart = widget.newButton({
    top = offset,
    width = 150,
    height = topMenu.height,
    id = "button1",
    label = "КОРЗИНА",
    onRelease = openCart
  })
  buttonCart.x = display.contentWidth - buttonCart.width*0.5,
  group:insert(buttonCart)
  
  --///////// TO CART ////////////////
  local function addCart(e) 
    if e.phase == "ended" then
      --[[
      globalCart[event.params.id]       = {}
      globalCart[event.params.id].url   = parent.params[event.params.id].url
      globalCart[event.params.id].title = parent.params[event.params.id].title
      globalCart[event.params.id].price = parent.params[event.params.id].price
      --]]
    end
  end
  --
  
  --////////// ROW RENDER /////////  
  local function rowRender(event)
    local row = event.row 
    
    --background
    local bg = display.newRect(row,0,0,row.contentWidth,row.contentHeight-5)
    bg:setFillColor(0.95)
    bg.anchorX = 0
    bg.anchorY = 0
    --
    
    local id
    if tonumber(row.params.id) <100 then id = "000" 
      elseif tonumber(row.params.id) >99 and tonumber(row.params.id) <200 then id = "100"
    else id = "200"; end
    --
    
    --remote image
    local image = display.loadRemoteImage( 
      url.."uploads/product/"..id.."/"..row.params.id.."/thumbs/30_"..self.params[row.params.id].url, 
      "GET", 
      function(e)
        if e == nil then return end
          if e.target  then
            e.target.anchorX = 0
            e.target.anchorY = 0
            e.target.x = 10
            e.target.y = 60
            e.target.alpha = 0
            transition.to( e.target, { alpha = 1.0 } )

            --////// fix bag ////--
            if row.insert then row:insert(e.target)
              else e.target:removeSelf();
            end
          end
      end,
      self.params[row.params.id].url, 
      system.TemporaryDirectory
    )
    --
  
    --title
    local title = display.newText(row, self.params[row.params.id].title, row.contentWidth/2,row.contentHeight*0.1,nil,32)
    title:setFillColor(.2)
    title.anchorY = 0
    title.align    = "center"
    
    --price
    local price = display.newText(row, self.params[row.params.id].price.." руб.", row.contentWidth*0.5,row.contentHeight-5,nil,32)
    price:setFillColor(0.2,0.5,0.2)
    price.anchorY = 1
    price.align   = "center"
      
    --///////// ROW TOUCH ///////// 
    function row:touch(e)
      if e.phase == "began" then
        return true
      elseif e.phase == "moved" then
        isMoved = true
      elseif e.phase == "ended" then
        if isMoved then isMoved=nil; return true end
        composer.showOverlay( "product", {isModal=true,effect = "fromRight",time=400,params={id=self.params.id,prodId = id}} )
        return true
      end 
    end
    row:addEventListener( "touch", row )
    
    --//////// BUTTON CART IMAGE ///////
    local buttonToCart = widget.newButton(    
      {
        x = row.width-10,
        y = row.height*0.5,
        width = 80,
        height = 80,
        defaultFile = "resources/cart.png",
        onEvent = addCart,
        name = "dfdfdf"
      })
    buttonToCart.anchorX = 1
    buttonToCart.anchorY = 0
    row:insert(buttonToCart)
  end
  --
  
  --///////// TABLE VIEW //////////
  local tableView = widget.newTableView{
    onRowRender = rowRender, 
    backgroundColor = {.2}, 
    top=offset+topMenu.height,
    height = display.contentHeight-(offset+topMenu.height)
  }
  group:insert(tableView)
  
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
      pleaseWait.text = "не могу подключиться\nсервер не доступен :'("
      pleaseWait:setFillColor(.9,0,0)
    else
      if ( event.phase == "progress" ) then
        pleaseWait.text = "получаю данные..."
      elseif ( event.phase == "ended" ) then
        if pleaseWait.removeSelf then pleaseWait:removeSelf() end
        local myNewData = event.response
        local decodedData = ( json.decode( myNewData ) )

        for i=1,#decodedData do
            self.params[decodedData[i][1]]= {}
            self.params[decodedData[i][1]].title = decodedData[i][3]
            self.params[decodedData[i][1]].price = decodedData[i][4]
            self.params[decodedData[i][1]].url   = decodedData[i][2]
            self.params[decodedData[i][1]].desc  = decodedData[i][6]
            
            tableView:insertRow{
              lineColor = { .2 },
              rowHeight = 220,
              rowColor = { default={.2} },
              params={id =decodedData[i][1],} 
            } 
        end  
      end
    end  
  end
end
--
function scene:show( event )
	local phase = event.phase
  if "will"== phase then
    local params={headers={},body="post=products&id="..event.params.id,progress="download"}
    network.request( url.."api2", "POST", self.getAPI, params)
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
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )
return scene
