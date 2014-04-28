local Bird = import("..sprites.Bird")
local Bullet = import("..sprites.Bullet")
local Timer = import("..utils.Timer")
local Utils = import("..utils.Utils")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local birdWidth, birdHeight = 34, 24
local bulletWidth, bulletHeight = 9, 9
local skyLevel = {display.top - 1/5 * display.height}
local speed = {2}
local bulletSpeed = 1

local startPotision = display.left - birdWidth
local endPosition = display.right + birdWidth


function MainScene:ctor()
    -- touchLayer 用于接收触摸事件
    self.touchLayer = display.newLayer()
    self:addChild(self.touchLayer)
    local bg = display.newSprite("#bg.png", display.cx, display.cy)
    bg:setScaleX(display.width / bg:getContentSize().width)
    bg:setScaleY(display.height / bg:getContentSize().height)
    self:addChild(bg)

    self.birds = {}
    self.birdTag = 0
    self.bullets = {}
    self.bulletTag = 0
end

function MainScene:genBird()
    local bird = Bird.new(startPotision, skyLevel[1])
    self:addChild(bird)
    self.birds[#self.birds + 1] = bird
    bird.tag = self.birdTag
    bird.isShoot = false
    self.birdTag = self.birdTag + 1

    self:birdFly(bird)
end

function MainScene:genBullet(x, y)
    local bullet = Bullet.new(x, y)
    self:addChild(bullet)
    self.bullets[#self.bullets + 1] = bullet
    bullet.tag = self.bulletTag
    bullet.isShoot = false
    self.bulletTag = self.bulletTag + 1

    self:shoot(bullet, x, y)
end

function MainScene:birdFly(bird)
    local action = CCMoveTo:create(speed[1], ccp(endPosition, skyLevel[1]))
    local action2 = CCCallFuncN:create(handler(self, self.birdFlyComplete))
    bird:runAction(transition.sequence({action,action2,}))
end

function MainScene:shoot(bullet, x, y)
    local action = CCMoveTo:create(bulletSpeed, ccp(x, display.top - y))
    local action2 = CCCallFuncN:create(handler(self, self.removeBullet))
    bullet:runAction(transition.sequence({action,action2,}))
end

function MainScene:birdFlyComplete(bird)
    bird:setPosition(ccp(startPotision, skyLevel[1]))
    self:birdFly(bird)
end

function MainScene:removeBullet(bullet)
    for i,v in ipairs(self.bullets) do
        if bullet.tag == v.tag then
            table.remove(self.bullets, i)
        end
    end
    self:removeChild(bullet, true)
end

function MainScene:removeBird(bird)
    for i,v in ipairs(self.birds) do
        if bird.tag == v.tag then
            table.remove(self.birds, i)
        end
    end
    self:removeChild(bird, true)
end

function MainScene:shootSuccess(_bird, _bullet)
    _bird:stopAllActions()
    _bullet:stopAllActions()
    _bird:setRotation(90)
    local x = _bird:getPositionX() - (_bird:getPositionY() - _bullet:getPositionY())
    local y = _bird:getPositionY() - (_bullet:getPositionX() - _bird:getPositionX())
    _bullet:setPosition(x, y)
    _bullet.isShoot = true
    _bird.isShoot = true

    local action1 = CCMoveTo:create(y / display.height * 1.0, ccp(_bird:getPositionX(), -20))
    local action2 = CCCallFuncN:create(handler(self, self.removeBird))
    local action = CCDelayTime:create(0.05)
    _bird:runAction(transition.sequence({action,action1, action2,}))

    local action3 = CCMoveTo:create(y / display.height * 1.0, ccp(_bullet:getPositionX(), -20))
    local action4 = CCCallFuncN:create(handler(self, self.removeBullet))
    _bullet:runAction(transition.sequence({action,action3, action4,}))
end

--[[
帧事件处理函数
@param dt
]]
function MainScene:updateFrame(dt)
    for i,_bird in ipairs(self.birds) do
        for _i,_bullet in ipairs(self.bullets) do
            local collision = Utils:isRectCollision(_bird, _bullet)
            if collision and not _bullet.isShoot and not _bird.isShoot then
                self:shootSuccess(_bird, _bullet)
            end
        end
    end

    if math.random(1, 5) == 1 and #self.birds < 5 then
        local flag = true
        for i,v in ipairs(self.birds) do
            local p = v:getPositionX()
            if p < birdWidth * 2 or p > display.width - birdWidth * 2 then
                flag = false
                break
            end
        end

        if flag  then
            self:genBird()
        end
    end

    if #self.birds == 0 then
        self:genBird()
    end
end

--[[
touch事件处理函数
@param event
@param x
@param y
]]
function MainScene:onTouch(event, x, y)
    self:genBullet(x, -10)
    return false
end

function MainScene:onEnter()
    self:genBird()
    self:scheduleUpdate(function(dt) self:updateFrame(dt) end)
    -- Timer.runOnce(function(dt) self:updateFrame(dt) end)

    -- 注册touch事件处理函数
    self.touchLayer:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self.touchLayer:setTouchEnabled(true)

    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then 
                    CCDirector:sharedDirector():endToLua()
                end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

function MainScene:onExit()
end

return MainScene
