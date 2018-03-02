local widget      = require("widget")
local composer    = require( "composer" )
local json        = require ( "json" )
local scene       = composer.newScene()
local offset      = display.topStatusBarContentHeight
local topMenu     = {height=70}
local summ        = 0

function scene:show( event )
	local phase = event.phase
  if "will"== phase then
    local group   = self.view
    local parent  = event.parent  
    globalEvent.parent  = parent
 
    --/////////// принимаем ответ ////////
    local getAPI = function(event)
      if ( event.isError ) then
      else
        if ( event.phase == "progress" ) then
        elseif ( event.phase == "ended" ) then
          local myNewData = event.response
          print(myNewData)
          globalCart = {}
          summ = 0
          self.tableView:deleteAllRows()
          return true
        end
      end  
    end
    --
    --///////// метод для ОФОРМИТЬ ////////
    local function openOrder()
      local postProduct = {url=""} 
      --получаем данные о товарах из корзины
      for k,v in pairs(globalCart) do
        postProduct.url=postProduct.url..tostring(v["url"])..","  --путь фото
      end

      local params={body=
          "post=cart&"..
          "price='"..summ.."'&"..
          "comment='Заказ с мобильного приложения'&"..
          "url=rolly/sety/a-14",
        progress="download"}
      network.request("http://www.xn--04-vlcinfg0e8c.xn--p1ai/api2", "POST", getAPI,params)
    end
    
    --//////////// кнопка ОФОРМИТЬ ////////
    local buttonOrder = widget.newButton({
      top       = offset,
      width     = 150,
      height    = topMenu.height,
      label     = "ОФОРМИТЬ",
      onRelease = openOrder
    })
    buttonOrder.x = display.contentWidth - buttonOrder.width*0.5,
    group:insert(buttonOrder)
      
    _self = self
    --////////// Отрисовка полей с товарами /////////  
    local function rowRender(event)
      local row     = event.row 
      
      --фон
      local bg      = display.newRect(row,0,0,row.contentWidth,row.contentHeight-5)
      bg.anchorX    = 0
      bg.anchorY    = 0   
      bg:setFillColor(0.95)
      
      --фото товара
      local image   = display.newImage(row,row.params.url,system.TemporaryDirectory,0,0)
      image.anchorX = 0;    image.anchorY = 0
      image.xScale  = 0.5;  image.yScale  = 0.5
      image.x       = 10;   image.y       = 10  
      
      --описание товара
      local title   = display.newText(row, row.params.title, row.contentWidth*0.5,row.contentHeight*0.1,nil,32)
      title.anchorY = 0
      title.align   = "center"
      title:setFillColor(.2)
      
      --цена товара
      local price   = display.newText(row,row.params.price.." руб.",row.contentWidth*0.5,row.contentHeight-5,nil,32)
      price.anchorY = 1
      price.align   = "center"
      price:setFillColor(0.2,0.5,0.2)
      
      --кнопка для удаления товара
      local remove  = display.newText(row, "X", row.contentWidth-10,row.contentHeight*0.5,nil,64)
      remove.anchorX= 1
      remove.align  = "center"
      remove:setFillColor(0.9,0.1,0.1)
      
      --метод удаления товара
      function remove:touch(e)
        if e.phase      == "began" then
          return true
        elseif e.phase  == "moved" then
          isMoved = true
        elseif e.phase  == "ended" then
          if isMoved then isMoved=nil; return true end
          _self.tableView:deleteRows({row.id},{slideLeftTransitionTime=300,slideUpTransitionTime=400})
          
          globalCart[row.params.id] = nil
          summ = summ - tonumber(row.params.price)
          return true
        end
      end
      remove:addEventListener( "touch", remove )
    end
    
   --///////// Таблица для товаров //////////
    self.tableView = widget.newTableView{
      onRowRender     = rowRender, 
      backgroundColor = {.2}, 
      top             = offset+topMenu.height,
      height          = display.contentHeight-(offset+topMenu.height)
    }
    group:insert(self.tableView)
    
    -- запихиваем товары в таблицу
    for k,v in pairs(globalCart) do
      self.tableView:insertRow{
        lineColor = { .2 },
        rowHeight = 100,
        rowColor  = { default={.2} },
        params    = {id =k, url=v["url"], title=v["title"], price=v["price"]} ,
      }
      summ = summ + tonumber(v["price"])
    end
  end
end
--
function scene:destroy( event ) 
  local group         = self.view
  group:removeSelf()
  globalEvent.parent  = nil
  group               = nil
end
scene:addEventListener( "show"    , scene )
scene:addEventListener( "destroy" , scene )
return scene
