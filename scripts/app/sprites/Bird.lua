local Bird = class("Bird", function(x, y)
	local birdFrames = display.newFrames("bird%02d.png", 1, 3)
    local birdAnimation = display.newAnimation(birdFrames, 0.5 / 3)
    local birdSprite = display.newSprite(birdFrames[1], x, y)
    birdSprite:setScale(display.width / 320)
    birdSprite:playAnimationForever(birdAnimation)

    return birdSprite
end)

function Bird:ctor(x, y)

end

return Bird