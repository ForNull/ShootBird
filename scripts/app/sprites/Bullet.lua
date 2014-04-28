local Bullet = class("Bullet", function(x, y)
	local bulletFrames = display.newFrames("bullet%02d.png", 1, 3)
    local bulletAnimation = display.newAnimation(bulletFrames, 0.1 / 3)
    local bulletSprite = display.newSprite(bulletFrames[1], x, y)
    bulletSprite:setScale(display.width / 320 * 1.5)
    bulletSprite:playAnimationForever(bulletAnimation)

    return bulletSprite
end)

function Bullet:ctor(x, y)

end


return Bullet