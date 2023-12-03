module(..., package.seeall)




--  BallInOurPenalty()   判断球是不是在本方禁区 (守门员技能函数使用)





-- 判断球是不是在本方禁区 (守门员技能函数使用)
BallInOurPenalty = function()
	local x = ball.posX()
	local y = ball.posY()
	if math.abs(y) < param.penaltyWidth/2 and x < -(param.pitchLength/2 - param.penaltyDepth) then
		return true
	else
		return false
	end
end
