module(..., package.seeall)


-- 1.跑位使用
--		canBallPassToPos(targetpos):	球能否直接到达targetpos

-- 2.传球使用
-- 		canFlatPassToRole(role1, role2)：	角色1能否平传到角色2


--3. 进攻和防守的转换

-- 	isAttackOrDef(role):		二方都未得球时，进攻还是防守
-- 	isDefOrAttack(role):		二方都未得球时，防守还是进攻	
-- 	isBallPassed(role):		是否向role方向传球
--  isBallNoPass(role) : 	球的方向是否已经偏离传球线,球被抢
--	attackDistSubDefDist(role):  值大于设定值,说明被抢球
--  isAllWirl(role) : 是否处于争球相持阶段




--4. play层面部分判断函数

	
--countEnemy(role):	 		判断多少个对方机器人在指定机器人的一定范围内
--countEnemyToBall(dist): 判断多少个机器人在球的一定范围内

--whirlPassOk(role1,role2):		判断是否传球转身完成	
--whirlRobotOk(role):			判断是否抢球转身完成
	



-- 1.跑位使用
-- 球能否直接到达targetpos(跑位技能函数时用)
	canBallPassToPos = function(targetpos)
		local p1 = ball.pos()
		local p2 = targetpos
		local seg = CGeoSegment:new_local(p1, p2)
		for i = 0, param.maxPlayer - 1 do
			if enemy.valid(i) then
				local enemyPoint = enemy.pos(i)				
				local projectionP = seg:projection(enemyPoint)
				local dist = projectionP:dist(enemyPoint)
				local isprjon = seg:IsPointOnLineOnSegment(projectionP)
				if dist < whtParam.canPassDist and isprjon then
					return false
				end
			end
		end
		return true
	end


-- 2.传球使用
-- 角色1能否平传到角色2
	canFlatPassToRole = function(role1, role2)
		if role2 ~= nil then
			if  player.num(role2) ~= -1 then
				local p1 = player.pos(role1)
				-- local p1 = ball.pos()
				local p2 = player.pos(role2)
				-- 取得二个角色的连线
				local seg = CGeoSegment:new_local(p1, p2)
				-- 循环所有的对方机器人角色
				for i = 0, param.maxPlayer-1 do
					if enemy.valid(i) then
						local enemyPoint = enemy.pos(i)
						-- 取得对方角色在我方机器人的连线上的投影点
						local enemyProjection = seg:projection(enemyPoint)
						-- 对方机器人和投影点的距离
						local dist = enemyProjection:dist(enemyPoint)
						-- 投影点在线内还是延长线上
						local isprjon = seg:IsPointOnLineOnSegment(enemyProjection)
						-- 如果对方机器人离连线距离在设定的范围内且投影点在线内,说明能阻挡传球线
						if dist < whtParam.canFlatDist and isprjon then
							return false
						end
					end
				end	
				-- 如果没有对方机器人可阻挡传球线,返回true	
				return true
			else  -- 需要传球的角色role2不存在
				return false
			end 
		else
			return false
		end 
	end



--3. 进攻和防守的转换

-- 二方都未得球时，进攻还是防守
isAttackOrDef =function(role)

	local tempOther = 9000
	local ballP = ball.pos()
	local tempOur = player.pos(role):dist(ballP)
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(ballP)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end	
	if tempOur < tempOther - whtParam.attaOrDefDist and ball.velMod() < whtParam.attaOrDefBallSpeed then
		return true
	else
		return false
	end 

end
-- 二方都未得球时，防守还是进攻	
isDefOrAttack =function(role)
	local tempOther = 9000
	local ballP = ball.pos()
	local tempOur = player.pos(role):dist(ballP)
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(ballP)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end		
	if tempOther < tempOur - whtParam.attaOrDefDist and ball.velMod() < whtParam.attaOrDefBallSpeed then
		return true
	else
		return false
	end 
end

-- 球的方向是否已经偏离传球线
isBallNoPass =function(role)
	local p1 = ball.pos()
	local p2 = player.pos(role)
	local ptrDir = ( p2 - p1 ):dir()
	-- 球移动方向弧度与球和role的弧度的偏差大于设定值
	if (math.abs(ball.velDir() - ptrDir) > whtParam.noPassAccuracy)  then
		return true
	else
		return false
	end
end

-- 是否向role方向传球
isBallPassed =function(role)
	local p1 = ball.pos()
	local p2 = player.pos(role)
	local ptrDir = ( p2 - p1 ):dir()
	local tempOther = 1000
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(p1)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end	
	-- 球移动方向弧度与球和role的弧度的偏差在设定范围内,且球速要大于设定值
	if tempOther < whtParam.ball2Enemy then 
		return false
	elseif (math.abs(ball.velDir() - ptrDir) < whtParam.passAccuracy) and (ball.velMod() > whtParam.ballVelMod) then
		return true
	else
		return false
	end
end


-- 判断球是否被敌方抢到
-- 二方离球的距离相差值,返回我方减去敌方的值
attackDistSubDefDist =function(role)
	local tempOther = 9000
	local ballP = ball.pos()
	local tempOur = player.pos(role):dist(ballP)
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(ballP)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end	
	
	return tempOur-tempOther
end


-- 二方离球的距离相差值,是否在一定范围内,表示争球
isAllWirl =function(role)
	local tempOther = 9000
	local ballP = ball.pos()
	local tempOur = player.pos(role):dist(ballP)
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(ballP)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end	
	if math.abs(tempOur-tempOther) < whtParam.wirlsubDist and ball.velMod() < whtParam.wirlBallSpeed then
		return true
	else
		return false 
	end 
end




--4. play层面部分判断函数

-- 判断多少个机器人在球的一定范围内
countEnemyToBall =function(dist)
	local count = 0
	local tempP = ball.pos()
	for i=0,param.maxPlayer-1 do
	    if  enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(tempP)
			if dist1 < dist then
					count = count + 1
			end 
	    end
	end
	return count
end

-- 判断多少个对方机器人在指定机器人的一定范围内
countEnemy =function(role,dist)
	local count = 0
	local tempP = player.pos(role)
	for i=0,param.maxPlayer-1 do
	    if  enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(tempP)
			if dist1 <  dist then
					count = count + 1
			end 
	    end
	end
	return count
end


--判断是否传球转身完成
whirlPassOk = function(role1,role2)	
	if math.abs(player.dir(role1)-player.toPlayerDir(role1,role2)) < whtParam.whirlArcToPassBall then  
		return true
	else
		return false
	end
end

--判断是否转身完成(带球移动前先作旋转动作,或抢球完成)
whirlRobotOk = function(role)	
	local playerP = player.pos(role)
	local minDis = 9000
	local minDisEnemy = 0
	-- 最得最近的对方机器人
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(playerP)		
			if dist1 < minDis then
				minDis = dist1
				minDisEnemy = i
			end
		end
	end	
	-- -- 距离在范围内，判断角度是否完成，否则直接返回完成
	-- if minDis < whtParam.needWhirlRobotDist then  
    local b2e =ball.toEnemyDir(minDisEnemy)
    local b2r = ball.toPlayerDir(role)		
	local subDir = math.abs(b2r-b2e)
	if subDir < whtParam.whirlArcCompare then
		return true
	else
		return false
	end
	-- else
	-- 	return true
	-- end		
end












