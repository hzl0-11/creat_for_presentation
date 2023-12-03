module(..., package.seeall)


--   prepareShootPos(dist,shootPos2EdgeDist,enemy2ShootLineDist)  直接射门时,寻找准备射门的位置
					-- dist 离球的距离
					-- shootPos2EdgeDist 射门目标点离球门边框的距离 
					-- enemy2ShootLineDist 对方机器人离射门线的垂直距离,距离内说明能挡住射门线


prepareShootPos = function(dist,shootPos2EdgeDist,enemy2ShootLineDist)
    return function()
		local ballPos = ball.pos()
		local goalPos1  -- 球门的二边点坐标
		local goalPos2
		-- 根据球的位置,确定先判断射哪边
		if ball.posY() > 0 then
			goalPos1 = CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2-shootPos2EdgeDist)
			goalPos2 = CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2+shootPos2EdgeDist)
		else
			goalPos1 = CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2+shootPos2EdgeDist)
			goalPos2 = CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2-shootPos2EdgeDist)
		end 
		--射门线段
		local seg1 = CGeoSegment:new_local(ballPos, goalPos1)
		-- 是否阻挡标志 true为没有阻挡
		local flag = true

		local enemyPoint  -- 对方机器人位置
		local prejectPos  -- 投影点
		local enemy2prejectPosDist -- 投影点和对方机器人的距离
		local isprjon --是否在线段内的标志

		for i = 0, param.maxPlayer-1 do		
			if enemy.valid(i) then
				enemyPoint = enemy.pos(i)
				prejectPos = seg1:projection(enemyPoint)
				isprjon = seg1:IsPointOnLineOnSegment(prejectPos)
				if 	isprjon then
					enemy2prejectPosDist = prejectPos:dist(enemyPoint)
					if enemy2prejectPosDist <  enemy2ShootLineDist then
						flag = false
						break
					end					
				end 			
			end
		end
		local idir
		local iPos
		if flag then
			idir = (ball.pos() - goalPos1):dir()
      		iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
      		return iPos 
		end
		flag = true  
		local seg2 = CGeoSegment:new_local(ballPos, goalPos2)

		for i = 0, param.maxPlayer-1 do		
			if enemy.valid(i) then
				enemyPoint = enemy.pos(i)
				prejectPos = seg2:projection(enemyPoint)
				isprjon = seg1:IsPointOnLineOnSegment(prejectPos)
				if 	isprjon then
					enemy2prejectPosDist = prejectPos:dist(enemyPoint)
					if enemy2prejectPosDist <  enemy2ShootLineDist then
						flag = false
						break
					end					
				end 			
			end
		end

		if flag then
			idir = (ball.pos() - goalPos2):dir()
      		iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
      		return iPos 
		else
     	    idir = (ball.pos() - pos.theirGoal()):dir()
		    iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
		    return iPos			
		end
    end 
end





--   prepareAroundBallPos(dist)  绕球旋转前,准备旋转的位置
					-- dist 离球的距离
					-- role 移动机器人

prepareAroundBallPos = function(role,dist)
    return function()
      local idir = (player.pos(role)- ball.pos()):dir()
      local iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
      return iPos
    end 
end




















-- 1.跑位使用
--		canBallPassToPos(targetpos):	球能否直接到达targetpos
--		canFlatShoot(point):			point这个点能否平射

-- 2.传球使用
-- 		canFlatPassToRole(role1, role2)：	角色1能否平传到角色2


-- 3.前进时使用
--		canAdvance(): 	能否前进
---- 	canFlatAdvance():	能否平推前进

--4. 进攻和防守的转换

-- 	isAttackOrDef(role):		二方都未得球时，进攻还是防守
-- 	isDefOrAttack(role):		二方都未得球时，防守还是进攻	
-- 	isBallPassed(role):		是否向role方向传球
--  isBallNoPass(role) : 	球的方向是否已经偏离传球线,球被抢
--	attackDistSubDefDist(role):  值大于设定值,说明被抢球
--  isAllWirl(role) : 是否处于争球相持阶段




--5. play层面部分判断函数
--canRobotFlatShoot(role):	机器人能否平射（带球时判断能不能射门或传球时，要使用机器人的点，不要使用球的位置）
	
--passObject(role,role1,role2,role3,role4,role5,role6):	计算传球的优先目标
	
--countEnemy(role):	 		判断多少个对方机器人在指定机器人的一定范围内
--countEnemyToBall(dist): 判断多少个机器人在球的一定范围内

--haveKicker(): 是否有开球车进入一定范围,任意球开球时判断是否开始防守
	
--whirlShootOk(role):			判断是否射门转身完成	
--whirlPassOk(role1,role2):		判断是否传球转身完成	
--whirlRobotOk(role):			判断是否抢球转身完成
	


-- 6. 点球使用
--		goalie2Attack()  		: 判断哪方离球更近，守方更近返回真。
-- 		distToGoalie()	 		: 对方守门员X坐标（射门用）
--		canFlatPenaltyShoot() 	: 能否平射


--7. 判断球的位置
--		BallInField():			球是否在场内
-- 		BallInOurPenalty():		判断球是不是在本方禁区 (守门员技能函数使用)

-- 		fieldIncludeOurPenalty():	判断球是不是在场内(本方禁区也算场内)(守门员函数技能使用)




-- 1.跑位使用
-- 球能否直接到达targetpos(跑位技能函数时用)
	-- 使用弧度判断
	canPassToPos = function(ballpos,targetpos,arc)
		local temArc = (targetpos - ballpos):dir()
		for i = 0, param.maxPlayer - 1 do
			if enemy.valid(i) then
				local enemyP = enemy.pos(i)
				if ballpos:dist(enemyP) < ballpos:dist(targetpos) then
					local B2EDir = (enemyP - ballpos):dir()	
					if math.abs(B2EDir- temArc) < arc then
						return false
					end
				end
			end
		end
		return true
	end

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
-- 能否平射

	canFlatShoot = function(point)
		local p1 = point
		local p2 = CGeoPoint:new_local(param.pitchLength/2,0)
		local seg = CGeoSegment:new_local(p1, p2)
		for i = 0, param.maxPlayer-1 do
			-- 排除守员门enemy.pos(i):dist(p2) > param.penaltyDepth 			
			if enemy.valid(i) and  enemy.pos(i):dist(p2) > param.penaltyDepth   then
				local enemyPoint = enemy.pos(i)
				local tempP = seg:projection(enemyPoint)
				local dist = tempP:dist(enemyPoint)
				local isprjon = seg:IsPointOnLineOnSegment(tempP)
				if dist <  whtParam.canFlatShootDist and isprjon then
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



-- 3.前进时使用
-- 能否前进
	canAdvance = function()
		local ballP = ball.pos()
		local objectP 
		--  先判断离球设定值的四周范围内,有没有对方角色存在
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i)  then
				local enemyPoint = enemy.pos(i)
				local dist = ballP:dist(enemyPoint)
				if dist < whtParam.canRoundDist then
					return false
				end
			end
		end
		-- 判断前进路上有没有对方角色存在,长度大于上一个判断
		if ball.posY()  > 0 then
			objectP = whtParam.advancePoint1
		else
			objectP = whtParam.advancePoint2
		end
		local movePoint = ballP + Utils.Polar2Vector(whtParam.advanceDist,(objectP-ballP):dir())
		local seg = CGeoSegment:new_local(ballP, movePoint)
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i)  then
				local enemyPoint = enemy.pos(i)
				local tempP = seg:projection(enemyPoint)
				local dist = tempP:dist(enemyPoint)
				local isprjon = seg:IsPointOnLineOnSegment(tempP)
				if dist < whtParam.canAdvanceDist and isprjon then
					return false
				end
			end
		end
		return true
	end
-- 平推前进或挑球前进
	canFlatAdvance = function()
		local ballP = ball.pos()
		local objectP 
		if ball.posY()  > 0 then
			objectP = whtParam.advancePoint1
		else
			objectP = whtParam.advancePoint2
		end
		local movePoint = ballP + Utils.Polar2Vector(whtParam.advanceDist,(objectP-ballP):dir())
		local seg = CGeoSegment:new_local(ballP, movePoint)
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i)  then
				local enemyPoint = enemy.pos(i)
				local tempP = seg:projection(enemyPoint)
				local dist = tempP:dist(enemyPoint)
				local isprjon = seg:IsPointOnLineOnSegment(tempP)
				if dist < whtParam.canFlatDist and isprjon then
					return false
				end
			end
		end
		return true
	end


--4. 进攻和防守的转换

-- 判断球是否被敌方抢到
-- isEnemyGrabBall =function()
-- 	local tempP = CGeoPoint:new_local(param.pitchLength / 2.0, 0)
-- 	local ballP = ball.pos()	
-- 	for i=0,param.maxPlayer-1 do
-- 	    -- 对方机器人离球在一定距离内,认为球能被它抢到
-- 	    if  enemy.valid(i) then
-- 	    	local enemyP = enemy.pos(i)
-- 	    	local dist1 = enemyP:dist(tempP)
-- 	    	local dist2 = enemyP:dist(ballP)
-- 	    	if dist1 > param.penaltyRadius and dist2 > 70 and dist2 < whtParam.ballToRoleDist then
-- 	      		return true
-- 	      	end
-- 	    end
-- 	end
-- 	return false
-- end

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
	if (math.abs(ball.velDir() - ptrDir) > whtParam.noPassAccuracy) and (ball.velMod() > whtParam.ballVelMod) then
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

isBallPassObject =function(role1,role2,role3)
	local objectRole ="E"
	local p2 
	local ptrDir
	local tempAccuracy = whtParam.passAccuracy
	local p1 = ball.pos()
	local tempOther = 1000
	local subArc	
	for i = 0, param.maxPlayer-1 do
		if enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(p1)		
			if dist1 < tempOther then
				tempOther = dist1
			end
		end
	end	
	-- 球离开对方机器人,且球速要大于设定值,表示在传球  移动方向弧度与球和role的弧度的偏差在设定范围内,
	if tempOther > whtParam.ball2Enemy  and (ball.velMod() > whtParam.ballVelMod) then 
			p2 = player.pos(role1)
			ptrDir = ( p2 - ball.pos() ):dir()
			subArc = math.abs(ball.velDir() - ptrDir)
		if subArc < tempAccuracy then
			tempAccuracy = subArc
			objectRole = role1
		end
			p2 = player.pos(role2)
			ptrDir = ( p2 - ball.pos() ):dir()
			subArc = math.abs(ball.velDir() - ptrDir)
		if subArc < tempAccuracy then
			tempAccuracy = subArc
			objectRole = role2
		end
			p2 = player.pos(role3)
			ptrDir = ( p2 - ball.pos() ):dir()
			subArc = math.abs(ball.velDir() - ptrDir)
		if subArc < tempAccuracy then
			tempAccuracy = subArc
			objectRole = role3
		end
	end
	return objectRole
end




--5. play层面使用
-- 机器人能否平射（带球时判断能不能射门或传球时，要使用机器人的点，不要使用球的位置）
	canRobotFlatShoot = function(role)
		local p1 = player.pos(role)
		local p2 = CGeoPoint:new_local(param.pitchLength/2,0)
		local seg = CGeoSegment:new_local(p1, p2)
		for i = 0, param.maxPlayer-1 do
			-- 排除守员门enemy.pos(i):dist(p2) > param.penaltyDepth 			
			if enemy.valid(i) and  enemy.pos(i):dist(p2) > param.penaltyDepth   then
				local enemyPoint = enemy.pos(i)
				local tempP = seg:projection(enemyPoint)
				local dist = tempP:dist(enemyPoint)
				local isprjon = seg:IsPointOnLineOnSegment(tempP)
				if dist <  whtParam.canFlatShootDist and isprjon then
					return false
				end
			end
		end
		return true
	end

--任意球计算传球的优先目标
 
 cornerPassObject = function(role,role1,role2)
 		local objectRole ="E"
		local countMax = 9 
		local maxDist = 12000
		local tempDist
		local tempCount
		local bothRobotDist
		local objectP = CGeoPoint:new_local(param.pitchLength/2,0) 
		local roleXPoint = player.posX(role)
		if roleXPoint > 5*param.pitchLength/24 then 
			if role1 ~= nil and player.num(role1) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role1))
				if  bothRobotDist > 1500 and canFlatPassToRole(role,role1)  then
					tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
					tempDist = player.pos(role1):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					elseif tempCount == countMax then		
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role1
						end
					end 
				end
			end 
			if role2 ~= nil and player.num(role2) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role2))
				if  bothRobotDist > 1500   and  canFlatPassToRole(role,role2)  then
					tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
					tempDist = player.pos(role2):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role2
						end
					end
				end
			end 
			if role3 ~= nil and player.num(role3) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role3))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role3)  then
					tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
					tempDist = player.pos(role3):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role3
						end
					end
				end
			end 
			if role4 ~= nil and player.num(role4) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role4))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role4)  then
					tempCount = countEnemy(role4,whtParam.enemy2PlayDist)
					tempDist = player.pos(role4):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role4
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role4
						end
					end
				end
			end 
			if role5 ~= nil and player.num(role5) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role5))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role5)  then
					tempCount = countEnemy(role5,whtParam.enemy2PlayDist)
					tempDist = player.pos(role5):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role5
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role5
						end
					end
				end
			end 

			if role6 ~= nil and player.num(role6) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role6))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role6)  then
					tempCount = countEnemy(role6,whtParam.enemy2PlayDist)
					tempDist = player.pos(role6):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role6
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role6
						end
					end
				end
			end 

		else
			if role1 ~= nil and player.num(role1) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role1))
				if bothRobotDist > 1500 and roleXPoint < player.posX(role1)
					and canFlatPassToRole(role,role1)  then
					tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
					tempDist = player.pos(role1):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					elseif tempCount == countMax then		
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role1
						end
					end 
				end
			end 
			if role2 ~= nil and player.num(role2) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role2))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role2)
					and  canFlatPassToRole(role,role2)  then
					tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
					tempDist = player.pos(role2):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role2
						end
					end
				end
			end
			if role3 ~= nil and player.num(role3) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role3))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role3)
					and canFlatPassToRole(role,role3)  then
					tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
					tempDist = player.pos(role3):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role3
						end
					end
				end
			end
			if role4 ~= nil and player.num(role4) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role4))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role4)
					and  canFlatPassToRole(role,role4)  then
					tempCount = countEnemy(role4,whtParam.enemy2PlayDist)
					tempDist = player.pos(role4):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role4
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role4
						end
					end
				end
			end
			if role5 ~= nil and player.num(role5) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role5))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role5)
					and  canFlatPassToRole(role,role5)  then
					tempCount = countEnemy(role5,whtParam.enemy2PlayDist)
					tempDist = player.pos(role5):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role5
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role5
						end
					end
				end
			end
			if role6 ~= nil and player.num(role6) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role6))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role6)
					and  canFlatPassToRole(role,role6)  then
					tempCount = countEnemy(role6,whtParam.enemy2PlayDist)
					tempDist = player.pos(role6):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role6
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role6
						end
					end
				end
			end
		end
		return objectRole
	end




















 directPassObject = function(role,role1,role2,role3,role4,role5,role6)
 		local objectRole ="E"
		local countMax = 9 
		local maxDist = 12000
		local tempDist
		local tempCount
		local bothRobotDist
		local objectP = CGeoPoint:new_local(param.pitchLength/2,0) 
		local roleXPoint = player.posX(role)
		if roleXPoint > 5*param.pitchLength/24 then 
			if role1 ~= nil and player.num(role1) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role1))
				if  bothRobotDist > 1500 and canFlatPassToRole(role,role1)  then
					tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
					tempDist = player.pos(role1):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					elseif tempCount == countMax then		
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role1
						end
					end 
				end
			end 
			if role2 ~= nil and player.num(role2) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role2))
				if  bothRobotDist > 1500   and  canFlatPassToRole(role,role2)  then
					tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
					tempDist = player.pos(role2):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role2
						end
					end
				end
			end 
			if role3 ~= nil and player.num(role3) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role3))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role3)  then
					tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
					tempDist = player.pos(role3):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role3
						end
					end
				end
			end 
			if role4 ~= nil and player.num(role4) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role4))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role4)  then
					tempCount = countEnemy(role4,whtParam.enemy2PlayDist)
					tempDist = player.pos(role4):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role4
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role4
						end
					end
				end
			end 
			if role5 ~= nil and player.num(role5) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role5))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role5)  then
					tempCount = countEnemy(role5,whtParam.enemy2PlayDist)
					tempDist = player.pos(role5):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role5
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role5
						end
					end
				end
			end 

			if role6 ~= nil and player.num(role6) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role6))
				if  bothRobotDist > 1500  and  canFlatPassToRole(role,role6)  then
					tempCount = countEnemy(role6,whtParam.enemy2PlayDist)
					tempDist = player.pos(role6):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role6
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role6
						end
					end
				end
			end 

		else
			if role1 ~= nil and player.num(role1) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role1))
				if bothRobotDist > 1500 and roleXPoint < player.posX(role1)
					and canFlatPassToRole(role,role1)  then
					tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
					tempDist = player.pos(role1):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					elseif tempCount == countMax then		
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role1
						end
					end 
				end
			end 
			if role2 ~= nil and player.num(role2) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role2))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role2)
					and  canFlatPassToRole(role,role2)  then
					tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
					tempDist = player.pos(role2):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role2
						end
					end
				end
			end
			if role3 ~= nil and player.num(role3) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role3))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role3)
					and canFlatPassToRole(role,role3)  then
					tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
					tempDist = player.pos(role3):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role3
						end
					end
				end
			end
			if role4 ~= nil and player.num(role4) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role4))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role4)
					and  canFlatPassToRole(role,role4)  then
					tempCount = countEnemy(role4,whtParam.enemy2PlayDist)
					tempDist = player.pos(role4):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role4
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role4
						end
					end
				end
			end
			if role5 ~= nil and player.num(role5) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role5))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role5)
					and  canFlatPassToRole(role,role5)  then
					tempCount = countEnemy(role5,whtParam.enemy2PlayDist)
					tempDist = player.pos(role5):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role5
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role5
						end
					end
				end
			end
			if role6 ~= nil and player.num(role6) ~= -1 then
				bothRobotDist = player.pos(role):dist(player.pos(role6))
				if  bothRobotDist > 1500 and roleXPoint < player.posX(role6)
					and  canFlatPassToRole(role,role6)  then
					tempCount = countEnemy(role6,whtParam.enemy2PlayDist)
					tempDist = player.pos(role6):dist(objectP)
					if tempCount < countMax then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role6
					elseif tempCount == countMax then			
						if tempDist < maxDist then
							countMax = tempCount
							maxDist= tempDist
							objectRole = role6
						end
					end
				end
			end
		end
		return objectRole
	end	
	-- directPassObject = function(role,role1,role2,role3,role4,role5,role6)
	-- 	local objectRole ="E"
	-- 	local countMax = 9 
	-- 	local maxDist = 12000
	-- 	local tempDist
	-- 	local tempCount
	-- 	local objectP = CGeoPoint:new_local(param.pitchLength/2,0) 
	-- 	if role1 ~= nil and player.num(role1) ~= -1 then
	-- 		if  whtFunction.canFlatPassToRole(role,role1)  then
	-- 			tempCount = countEnemy(role1,whtParam.directEnemy2PlayDist)
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role1
	-- 			elseif tempCount == countMax then				
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role1
	-- 				end
	-- 			end
	-- 		end 
	-- 	end
	-- 	if role2 ~= nil and player.num(role2) ~= -1 then
	-- 		if  whtFunction.canFlatPassToRole(role,role2)  then
	-- 			tempCount = countEnemy(role2,whtParam.directEnemy2PlayDist)
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role2
	-- 			elseif tempCount == countMax then			
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role2
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- 	if role3 ~= nil and player.num(role3) ~= -1 then
	-- 		if  whtFunction.canFlatPassToRole(role,role3)  then
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			tempCount = countEnemy(role3,whtParam.directEnemy2PlayDist)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role3
	-- 			elseif tempCount == countMax then		
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role3
	-- 				end
	-- 			end
	-- 		end 
	-- 	end
	-- 	if role4 ~= nil and player.num(role4) ~= -1 then 
	-- 		if   whtFunction.canFlatPassToRole(role,role4)  then
	-- 			tempCount = countEnemy(role4,whtParam.directEnemy2PlayDist)
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role4
	-- 			elseif tempCount == countMax then		
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role4
	-- 				end
	-- 			end
	-- 		end 
	-- 	end
	-- 	if role5 ~= nil and player.num(role5) ~= -1 then
	-- 		if whtFunction.canFlatPassToRole(role,role5)  then
	-- 			tempCount = countEnemy(role5,whtParam.directEnemy2PlayDist)
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role5
	-- 			elseif tempCount == countMax then			
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role5
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- 	if role6 ~= nil and player.num(role6) ~= -1 then
	-- 		if   whtFunction.canFlatPassToRole(role,role6)  then
	-- 			tempCount = countEnemy(role6,whtParam.directEnemy2PlayDist)
	-- 			tempDist = player.pos(role2):dist(objectP)
	-- 			if tempCount < countMax then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role6
	-- 			elseif tempCount == countMax then				
	-- 				if tempDist < maxDist then
	-- 					countMax = tempCount
	-- 					maxDist= tempDist
	-- 					objectRole = role6
	-- 				end
	-- 			end
	-- 		end 
	-- 	end
		-- if role6 ~= nil and player.num(role6) ~= -1 then
		-- 	if  player.velMod(role6) < whtParam.ballMoveMod and  whtFunction.canFlatPassToRole(role,role6)  then
		-- 		tempCount = countEnemy(role6,whtParam.directEnemy2PlayDist)
		-- 		if tempCount < countMax then
		-- 			countMax = tempCount
		-- 			objectRole = role6
		-- 		end
		-- 	end 
		-- end
	-- 	return objectRole
	-- end

--过程中计算传球的优先目标
	passObject = function(role,role1,role2,role3)
		local objectRole ="E"
		local countMax = 9 
		local maxDist = 12000
		local tempDist
		local tempCount
		local bothRobotDist
		local objectP = CGeoPoint:new_local(param.pitchLength/2,0) 
		local roleXPoint = player.posX(role)
		if roleXPoint > 5*param.pitchLength/24 then 
			bothRobotDist = player.pos(role):dist(player.pos(role1))
			if player.num(role1) ~= -1  and bothRobotDist > 1500 and canFlatPassToRole(role,role1)  then
				tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
				tempDist = player.pos(role1):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role1
				elseif tempCount == countMax then		
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					end
				end 
			end
			bothRobotDist = player.pos(role):dist(player.pos(role2))
			if player.num(role2) ~= -1 and bothRobotDist > 1500   and  canFlatPassToRole(role,role2)  then
				tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
				tempDist = player.pos(role2):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role2
				elseif tempCount == countMax then			
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					end
				end
			end
			bothRobotDist = player.pos(role):dist(player.pos(role3))
			if player.num(role3) ~= -1 and bothRobotDist > 1500  and  canFlatPassToRole(role,role3)  then
				tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
				tempDist = player.pos(role3):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role3
				elseif tempCount == countMax then			
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					end
				end
			end
		else
			bothRobotDist = player.pos(role):dist(player.pos(role1))
			if player.num(role1) ~= -1  and bothRobotDist > 1500 
				and roleXPoint < player.posX(role1)
				and canFlatPassToRole(role,role1)  then
				tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
				tempDist = player.pos(role1):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role1
				elseif tempCount == countMax then		
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role1
					end
				end 
			end
			bothRobotDist = player.pos(role):dist(player.pos(role2))
			if player.num(role2) ~= -1 and bothRobotDist > 1500   
				and roleXPoint < player.posX(role2)
				and  canFlatPassToRole(role,role2)  then
				tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
				tempDist = player.pos(role2):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role2
				elseif tempCount == countMax then			
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role2
					end
				end
			end
			bothRobotDist = player.pos(role):dist(player.pos(role3))
			if player.num(role3) ~= -1 and bothRobotDist > 1500  
				and roleXPoint < player.posX(role3)
				and canFlatPassToRole(role,role3)  then
				tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
				tempDist = player.pos(role3):dist(objectP)
				if tempCount < countMax then
					countMax = tempCount
					maxDist= tempDist
					objectRole = role3
				elseif tempCount == countMax then			
					if tempDist < maxDist then
						countMax = tempCount
						maxDist= tempDist
						objectRole = role3
					end
				end
			end
		end
		return objectRole
	end
	-- passObject = function(role,role1,role2,role3)
	-- 	local objectRole ="E"
	-- 	local countMax = 9 
	-- 	local maxDist = 12000
	-- 	local tempDist
	-- 	local tempCount
	-- 	local objectP = CGeoPoint:new_local(param.pitchLength/2,0) 
	-- 	if player.num(role1) ~= -1  and  whtFunction.canFlatPassToRole(role,role1)  then
	-- 		tempCount = countEnemy(role1,whtParam.enemy2PlayDist)
	-- 		tempDist = player.pos(role2):dist(objectP)
	-- 		if tempCount < countMax then
	-- 			countMax = tempCount
	-- 			maxDist= tempDist
	-- 			objectRole = role1
	-- 		elseif tempCount == countMax then		
	-- 			if tempDist < maxDist then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role1
	-- 			end
	-- 		end 
	-- 	end
	-- 	if player.num(role2) ~= -1   and  whtFunction.canFlatPassToRole(role,role2)  then
	-- 		tempCount = countEnemy(role2,whtParam.enemy2PlayDist)
	-- 		tempDist = player.pos(role2):dist(objectP)
	-- 		if tempCount < countMax then
	-- 			countMax = tempCount
	-- 			maxDist= tempDist
	-- 			objectRole = role2
	-- 		elseif tempCount == countMax then			
	-- 			if tempDist < maxDist then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role2
	-- 			end
	-- 		end
	-- 	end
	-- 	if player.num(role3) ~= -1  and  whtFunction.canFlatPassToRole(role,role3)  then
	-- 		tempCount = countEnemy(role3,whtParam.enemy2PlayDist)
	-- 		tempDist = player.pos(role2):dist(objectP)
	-- 		if tempCount < countMax then
	-- 			countMax = tempCount
	-- 			maxDist= tempDist
	-- 			objectRole = role3
	-- 		elseif tempCount == countMax then			
	-- 			if tempDist < maxDist then
	-- 				countMax = tempCount
	-- 				maxDist= tempDist
	-- 				objectRole = role3
	-- 			end
	-- 		end
	-- 	end
	-- 	return objectRole
	-- end



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




-- 任意球开球时判断是否开始防守
-- 是否有开球车进入一定范围
	haveKicker =function()
		local ballP = ball.pos()
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i)  then
				local enemyPoint = enemy.pos(i)
				local dist = ballP:dist(enemyPoint)
				if dist < whtParam.exceptDist1  then
					return true
				end
			end
		end
		return false
	end 	


--判断是否射门转身完成
	whirlShootOk = function(role)	
		if math.abs(player.toTheirGoalDir(role)-player.dir(role)) < 0.04 then  
			return true
		else
			return false
		end
	end

--判断是否射门转身完成
	CSwhirlShootOk = function(role)	
		if math.abs(player.toTheirGoalDir(role)-player.dir(role)) < whtParam.CSwhirlArcToShoot then  
			return true
		else
			return false
		end
	end

--判断是否绕球射门转身完成
	aroundBallShootOk = function(role)	
		if math.abs(player.toTheirGoalDir(role)-dir.playerToBall(role)) < whtParam.whirlArcToShoot then  
			return true
		else
			return false
		end
	end

--判断是否绕球射门转身完成
	CSaroundBallShootOk = function(role)	
		if math.abs(player.toTheirGoalDir(role)-dir.playerToBall(role)) < whtParam.CSroundBallToShoot then  
			return true
		else
			return false
		end
	end



--判断是否传球转身完成
	whirlPassOk = function(role1,role2)	
		if math.abs(player.dir(role1)-player.toPlayerDir(role1,role2)) < 0.06 then  
			return true
		else
			return false
		end
	end

--判断是否转身完成,带球移动前先作旋转动作
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
	-- 距离在范围内，判断角度是否完成，否则直接返回完成
	if minDis < whtParam.needWhirlRobotDist then  
        local b2e =ball.toEnemyDir(minDisEnemy)
	    local b2r = ball.toPlayerDir(role)		
		local subDir = math.abs(b2r-b2e)
		if subDir < whtParam.whirlArcCompare then
			return true
		else
			return false
		end
	else
		return true
	end		
end


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


-- 判断是否有对方机器人在球的一定圆形范围内
haveEnemyToBall =function(dist)
	local tempP = ball.pos()
	for i=0,param.maxPlayer-1 do
	    if  enemy.valid(i) then
			local dist1 = enemy.pos(i):dist(tempP)
			if dist1 < dist then
					return true
			end 
	    end
	end
	return false
end

-- 判断是否有对方机器人在指定机器人的一定弧度范围内
haveEnemyToPlay =function(role,dist)
	local tempP = player.pos(role)
	local tempX = tempP:x()
	for i=0,param.maxPlayer-1 do
	    if  enemy.valid(i) then
	    	local enemyP = enemy.pos(i)
			local dist1 = enemyP:dist(tempP)
			if dist1 <  dist then
				local pTeDir = (enemyP - tempP):dir()
				if tempX < param.pitchLength/2 - 2500 then  -- 此位置与直线移动技能中的位置一样
					if  math.abs(pTeDir) < math.pi/3 then
							return true
					end
				else
					if  math.abs(pTeDir) > 3*math.pi/4 then
							return true
					end
				end 
			end  
	    end
	end
	return false
end




-- 6. 点球使用
-- 哪方离球更近，确定守门员是否出击
	goalie2Attack =function()
		local tempEnemy = 8000
		local tempOur = 9000
		local ballX = ball.posX()
		local ballP = ball.pos()
		-- 寻找本方守门员车号，一般情况，守门员车位固定，不需要查找
		-- 计算守门员与球的距离
		for i = 0, param.maxPlayer-1 do
		    if  player.valid(i) then
				local dist1 = player.posX(i)
				if dist1 < ballX then
						tempOur = player.pos(i):dist(ballP)	
						break
				end 
		    end
		end	
		--寻找对方离球最近的机器人
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist2 = enemy.pos(i):dist(ballP)		
				if dist2 < tempEnemy then
					tempEnemy = dist2
				end
			end
		end		
		--如果对方离球更远，返回真（守门员出击）
		if tempEnemy > tempOur then
			return true
		else
			return false
		end

	end

-- 返回对方守门员X坐标（射门用）
	distToGoalie =function()
		local tempX = param.pitchLength/2
		local tempBX = ball.posX()
		for i=0,param.maxPlayer-1 do
		    if  enemy.valid(i) then
				local dist1 = enemy.posX(i)
				if dist1 > tempBX then
						tempX = dist1
						break
				end 
		    end
		end
		return tempX
	end	
-- 能否平射
	canFlatPenaltyShoot = function()
		local p1 = ball.pos()
		local ballX = ball.posX()
		local p2 = CGeoPoint:new_local(param.pitchLength/2,0)
		local seg = CGeoSegment:new_local(p1, p2)
		for i = 0, param.maxPlayer-1 do
			-- 取得守门员车号			
			if enemy.valid(i) and  enemy.posX(i) > ballX   then
				local enemyPoint = enemy.pos(i)
				local tempP = seg:projection(enemyPoint)
				local dist = tempP:dist(enemyPoint)
				if dist < whtParam.canFlatPenaltyShootDist  then
					return false
				end
			end
		end
		return true
	end




--7. 判断球的位置

--球是否在场内
BallInField = function()
	-- 取球及场地的x,y位置
	local x = ball.posX()
	local y = ball.posY()
	local mx = param.pitchLength / 2
	local my = param.pitchWidth / 2
	-- 如果球无效,返回false
	if not ball.valid() then
		return false
	-- 如果球在场外,返回false		
	elseif x > mx or x < -mx or y > my or y < -my then
		return false
	-- 如果球在二个禁区内,返回false		
	-- elseif math.abs(y) < param.penaltyWidth/2 and math.abs(x) > (mx - param.penaltyDepth) then
	-- 	return false
	else 
		return true
	end
end

--如果球在场内,由于视觉原因消失不见(或不在场内),如何得到前一个可见位置
-- 不能直接去得到二维坐标,需要分别得到x, y ,再组合成一个点返回
function previousBallPos()
	-- 初始设为0
    local x = CGeoPoint:new_local(0,0)
    return function ()        
        if BallInField() then
        	-- 如果球还在,赋值给X ,不在,保值X原值
        	x = CGeoPoint:new_local(ball.posX(),ball.posY())
        end 
        return x
    end
end


function previousBallPosAndDir()
	-- 初始设为0
    local x = CGeoPoint:new_local(0,0)
    local dir = 0
    local mod = 0
    local b2x = function ()        
        if BallInField() then
        	-- 如果球还在,赋值给X ,不在,保值X原值
        	x = CGeoPoint:new_local(ball.posX(),ball.posY())
        end 
        return x
    end
    local b2dir = function ()        
        if BallInField() then
        	-- 如果球还在,赋值
        	dir = ball.velDir()
        end 
        return dir
    end
     local b2mod = function ()        
        if BallInField() then
        	-- 如果球还在,赋值
        	mod = ball.velMod()
        end 
        return mod
    end
    return b2x, b2dir,b2mod
end



function preDirSubnowDir()
	-- 初始设为0
    local preDir = 0
    local nowDir = 0
    local NowDir = function ()        
	     if BallInField() then
	    	-- 如果球还在,赋值
	    	nowDir = ball.velDir()
	    end      
	    return nowDir
    end

    local SubDir = function ()       
        local subDir = nowDir - preDir   
        return subDir
    end
    local PreDir = function ()        
	    local pre2Dir = preDir 
	     if BallInField() then
	    	-- 如果球还在,赋值
	    	preDir = ball.velDir()
	    end      
	    return pre2Dir
    end    
    return NowDir,SubDir,PreDir
end






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

-- 判断球是不是在场内(本方禁区也算场内)(守门员函数技能使用)
fieldIncludeOurPenalty = function()
	local x = ball.posX()
	local y = ball.posY()
	local mx = param.pitchLength/2
	local my = param.pitchWidth	/2
	if not ball.valid() then
		return false
	elseif x > mx or x < -mx or y > my or y < -my then
		return false
	elseif math.abs(y) < param.penaltyWidth/2 and x > (mx - param.penaltyDepth) then
		return false
	else
		return true			
	end
end
	

function preSpeedSubnowSpeed()
	-- 初始设为0
    local preSpeed = 0
    local nowSpeed = 0
    local NowSpeed = function (role)        
	     if BallInField() then
	    	-- 如果球还在,赋值
	    	nowSpeed = player.velMod(role)
	    end      
	    return nowSpeed
    end

    local SubSpeed = function ()       
        local subSpeed = nowSpeed - preSpeed   
        return subSpeed
    end
    local PreSpeed = function (role)        
	    local pre2Speed = preSpeed
	     if BallInField() then
	    	-- 如果球还在,赋值
	    	preSpeed = player.velMod(role)
	    end      
	    return pre2Speed
    end    
    return NowSpeed,SubSpeed,PreSpeed
end



