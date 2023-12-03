module(..., package.seeall)

--~		C++中统一处理的参数,不能的技能有不同的参数:

--~		GoCmuRush : 移动到pos确定的目标点
--~		GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
--~		pos: 技能目标点(传入的ipos为函数名)
--~		dir: 角色的弧度(传入的idir为函数名)
--~		acc: 角色的移动速度(传入的a为速度常量值)
--~		flag: 状态标志(传入的f为标志常量值)

--~		Play中统一处理的参数（主要是开射门）(8个参数顺序不能变,名称能变) 
--~		1 ---> task, 2 ---> matchpos :  技能函数的返回值 
--~		3---->kick, 4 ---->dir 		 :  是否踢球(包括平,挑射)  和 角色弧度    (函数名)
--~		5 ---->pre,  				 :  踢球的精度   (函数名)
--~		6 ---->kp,       7---->cp,   :  平射和挑射的力度   (函数名)
--~		8 ---->flag 				 :  状态标志   (标志常量值)
--~		要不只使用前面2个参数,要不全部使用



-- 自定义技能函数:
-- 1. 截球设计		
-- 					interBall(role)

-- 2. 跑位设计		
-- 					runPos(role,n)

-- 3. 传球设计		
--					passBall(role,role1)	任意球发球时使用（不吸球）
--					kickBall(role,role1)	传球时使用(吸球)	

-- 4. 带球设计		


-- 5. 抢球设计		
-- 					grabBall(role)
-- 					grabBall1(role)

-- 6. 旋转设计	
--6.1 					whirlRobotToPassBall(role,role1) : 旋转到传球方向(吸球方式)
--6.2 					whirlRobotAroundBallToRobot(role,role1) : 围绕球旋转到传球方向
--6.3 					whirlRobotToCarry(role) : 吸着球转身（可用来与对方争抢球）


-- 7. 协防			
-- 					robotDef(role,n)  


-- 8. 其它



-- 1. 截球设计
-- 速度大于moveSpeed1时:运动到来球方向的垂直点上接球
-- 速度大于moveSpeed2时:向来球方向运动,保持离球某个距离(distToBall)
-- 速度小于moveSpeed2时:直接向球运动拿球
function interBall(role)
	local ipos =function()		
		-- 速度大于moveSpeed1时, 返回投影点
		if ball.velMod() >skillParam.moveSpeed1 then
			local playerP = player.pos(role)
			local ballP = ball.pos()
			local movePoint = ballP + Utils.Polar2Vector(1000,ball.velDir())
			local seg = CGeoSegment:new_local(ballP, movePoint)
			local intersectionP = seg:projection(playerP)
			return  intersectionP
		-- 速度大于moveSpeed2时, 向球移动,离球一定距离
		elseif ball.velMod() >skillParam.moveSpeed2 then
			return ball.pos() + Utils.Polar2Vector(skillParam.distToBall,ball.velDir())
		-- 速度小于moveSpeed2时, 向球移动,吸球
		else
			return ball.pos() 
		end
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss+flag.dribbling
	-- local a = 500
	-- 移动速度a未设定,保持默认值
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 2. 跑位设计
function runPos(role,n)
	local ipos =function()	
		local p1 = CGeoPoint:new_local(0,0)
		local p1toRoleDir = (player.pos(role)- p1):dir()

		local X = {p1 + Utils.Polar2Vector(skillParam.roleToCenter, p1toRoleDir + 2*math.pi/3),
					p1 + Utils.Polar2Vector(skillParam.roleToCenter, p1toRoleDir - 2*math.pi/3)
				}	
		
		for i = 0 ,2 do
			if X[1]:x() > 0 then
				temp = X[1] +  Utils.Polar2Vector(500,  math.pi/2-i*math.pi/2)
			else
				temp = X[1] +  Utils.Polar2Vector(500,  math.pi/2+i*math.pi/2)
			end
			if whtFunction.canBallPassToPos(temp) then
				X[1] =temp
				break
			end 
		end	
		for i = 0 ,2 do
			if X[2]:x() > 0 then
				temp = X[2] +  Utils.Polar2Vector(500,  math.pi/2-i*math.pi/2)
			else
				temp = X[2] +  Utils.Polar2Vector(500,  math.pi/2+i*math.pi/2)
			end
			if whtFunction.canBallPassToPos(temp) then
				X[2] =temp
				break
			end 
		end	

		if n == 1 then
			return X[1]
		else
			return X[2]
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss + flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 3. 传球设计

-- 	发球时使用	
function passBall(role,role1)
	local pos1 = function()
		return ball.pos()			
	end
local ikick = function()
		if skillFunction.canFlatPassToRole(role,role1) then
			return 1
		else
			return 2
		end
end	
	local idir = function()
		return (player.pos(role1) - player.pos(role)):dir()
	end

	-- local ipos = pos1()     
    function specifiedFlat()
	   local pw 
	   if IS_SIMULATION then
	  		pw =  (ball.pos():dist(player.pos(role1)))*skillParam.simulationTimes + skillParam.simulationCompensate
	  		if pw < skillParam.simulationMinPower then   
				pw = skillParam.simulationMinPower 					
			elseif pw > skillParam.simulationMaxPower then
				pw = skillParam.simulationMaxPower
			end
			return pw
	   else
	  		pw =  (ball.pos():dist(player.pos(role1)))*skillParam.realTimes + skillParam.realCompensate
			if pw < skillParam.realMinPower then    
				pw = skillParam.realMinPower 			
			elseif pw > skillParam.realMaxPower then
				pw = skillParam.realMaxPower
			end
			return pw
			-- return 300
	   end 
	end
	function specifiedChip()
		local pw 
		if IS_SIMULATION then
	  		pw =  (ball.pos():dist(player.pos(role1))) * skillParam.simulationChipTimes
			if pw < skillParam.simulationChipMinPower then    
				pw = skillParam.simulationChipMinPower			
			elseif pw > skillParam.simulationChipMaxPower then
				pw = skillParam.simulationChipMaxPower
			end
			return pw
	   else
	  		pw =  (ball.pos():dist(player.pos(role1))) * skillParam.realChipTimes
			if pw < skillParam.realChipMinPower then    
				pw = skillParam.realChipMinPower			
			elseif pw > skillParam.realChipMaxPower then
				pw = skillParam.realChipMaxPower		
			end
			return pw
			-- return 2000
	   end 
	end
	local mexe, mpos = GoCmuRush{pos = pos1, dir = idir, acc = 1000, flag = flag.allow_dss,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.high, specifiedFlat, specifiedChip, flag.allow_dss}

end 

 -- 传球使用
function kickBall(role,role1)
		local pos1 = function()
			return player.pos(role1)			
		end
		local ikick = function()
			if skillFunction.canFlatPassToRole(role,role1) then
				return 1
			else
				return 2
			end
		end			
		local idir = function()
			return (pos1() - player.pos(role)):dir()
		end
   
		local ipos = pos1()     
	    function specifiedFlat()
		   local pw 
		   if IS_SIMULATION then
		  		pw =  (ball.pos():dist(ipos))*skillParam.simulationTimes + skillParam.simulationCompensate
		  		if pw < skillParam.simulationMinPower then   
					pw = skillParam.simulationMinPower 					
				elseif pw > skillParam.simulationMaxPower then
					pw = skillParam.simulationMaxPower
				end
				return pw
		   else
		  		pw =  (ball.pos():dist(ipos))*skillParam.realTimes + skillParam.realCompensate
				if pw < skillParam.realMinPower then    
					pw = skillParam.realMinPower 			
				elseif pw > skillParam.realMaxPower then
					pw = skillParam.realMaxPower
				end
				return pw
				-- return 300
		   end 
		end
		function specifiedChip()
			local pw 
			if IS_SIMULATION then
		  		pw =  (ball.pos():dist(ipos)) * skillParam.simulationChipTimes
				if pw < skillParam.simulationChipMinPower then    
					pw = skillParam.simulationChipMinPower			
				elseif pw > skillParam.simulationChipMaxPower then
					pw = skillParam.simulationChipMaxPower
				end
				return pw
		   else
		  		pw =  (ball.pos():dist(ipos)) * skillParam.realChipTimes
				if pw < skillParam.realChipMinPower then    
					pw = skillParam.realChipMinPower			
				elseif pw > skillParam.realChipMaxPower then
					pw = skillParam.realChipMaxPower		
				end
				return pw
				-- return 2000
		   end 
		end
		local mexe, mpos = Touch{pos = pos1}
		return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss+flag.dribbling}
		-- return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.nothing}
end 

-- 4. 带球设计



-- 5. 抢球设计
-- 如果角色直接能运行到球坐标,直接向球坐标移动
-- 如果对方机器人挡住了直线移动,且球离对方机器人200毫米内,绕到对方机器人的前面,到离球300毫米处
-- 如果对方机器人只是挡住了直线移动,还是直接向球坐标移动(通过避障功能自动避开对方机器人)
function grabBall(role)
	local ipos =function()
		-- 球正在移动,向球的移动方向前面跑
		if	ball.velMod() > skillParam.grabBallSpeed then
			return ball.pos() + Utils.Polar2Vector(skillParam.grabToBallDist,ball.velDir())
		else
			local playerP = player.pos(role)
			local p2 = ball.pos()
			local seg = CGeoSegment:new_local(playerP, p2)
			for i = 0, param.maxPlayer - 1 do
				if enemy.valid(i) then
					local enemyPoint = enemy.pos(i)
					local projectionP = seg:projection(enemyPoint)
					local dist = projectionP:dist(enemyPoint)
					local isprjon = seg:IsPointOnLineOnSegment(projectionP)
					-- 有对方机器人阻挡抢球线,且离球距离在设定值内,绕到对方机器人的前面p2
					if dist < skillParam.grabBlockDist and isprjon and enemyPoint:dist(p2) < skillParam.grabBalltoRole then
						return ball.pos() + Utils.Polar2Vector(skillParam.grabRoundDist,(p2-enemyPoint):dir())
					end
				end
			end
			return  ball.pos() 
		end 

	end
	local idir = dir.playerToBall
	-- local f = flag.dribbling 	
	local f = flag.dribbling + flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

function grabBall1(role)
	local ipos =function()
		local ballP = ball.pos()
		for i=0,param.maxPlayer-1 do
		    -- 对方机器人离球在一定距离内,认为它持球
		    if  enemy.valid(i) 
		    		and enemy.pos(i):dist(ballP) < skillParam.ballToRoleDist  then
		      	return enemy.pos(i) + Utils.Polar2Vector(skillParam.nearToRoleDist,(player.pos(role)-enemy.pos(i)):dir())
		    end
		end
		return player.pos(role)
	end
	local idir = dir.playerToBall
	local f = flag.dribbling
	-- local f = flag.dribbling + flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 6 旋转设计
-- 6.1 旋转到传球方向(吸球方式)
function whirlRobotToPassBall(role,role1)
	local spdW = function()
		local playerDir =player.dir(role)
        local playerToGoal = (player.pos(role1)-player.pos(role)):dir()
        -- 二者弧度相差一定范围内,表示到达目标
        if math.abs(playerToGoal-playerDir) > skillParam.whirlArcToPassBall  then
            -- 通过二者弧度位置,得到顺时针还是逆时针
            if playerToGoal < 0 then
	            if  playerDir > playerToGoal and playerDir < math.pi + playerToGoal then
	           		if IS_SIMULATION then
						return skillParam.whirlSimulationSpeed1
			   		else
						return skillParam.whirlSpeed1
			   		end 
	           	else
	           		if IS_SIMULATION then
						return skillParam.whirlSimulationSpeed
			   		else
						return skillParam.whirlSpeed
			   		end 
	           	end
	        else
	            if  playerDir < playerToGoal and playerDir > playerToGoal - math.pi   then
	           		if IS_SIMULATION then
						return skillParam.whirlSimulationSpeed
			   		else
						return skillParam.whirlSpeed
			   		end 
	           	else
	           		if IS_SIMULATION then
						return skillParam.whirlSimulationSpeed1
			   		else
						return skillParam.whirlSpeed1
			   		end 
	           	end
	        end          
        else
            return 0 
        end	
	end
	local idir =function()
		return player.dir(role)
	end
	local ikick = function()
		return 0
	end
    function specifiedFlat()
	   return 0 
	end
    function specifiedChip()
		return 0
	end
	local mexe, mpos = OpenSpeed{speedW = spdW}
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end

-- 6.2 围绕球旋转到传球方向
function whirlRobotAroundBallToRobot(role,role1)
	local ipos = function()		
		local playerDir =dir.playerToBall(role)
    	local playerToGoal = player.toPlayerDir(role,role1)	
    	if math.abs(playerToGoal-playerDir) > skillParam.whirlArcToPassBall  then
        -- 通过二者弧度位置,得到顺时针还是逆时针
            if  playerDir < playerToGoal then
           		return  ball.pos() + Utils.Polar2Vector(skillParam.whirlDist,dir.ballToPlayer(role)+skillParam.detAngle)
           	else
           		return  ball.pos()  + Utils.Polar2Vector(skillParam.whirlDist,dir.ballToPlayer(role)-skillParam.detAngle)
           	end       		
		else
			return player.pos(role)
		end			

	end 
	local idir =function()
		return dir.playerToBall(role)
	end
	local ikick = function()
		return 0
	end
    function specifiedFlat()
		return 0
	end
    function specifiedChip()
		return 0
	end
	local f = flag.allow_dss
	-- a = 1000
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,f}
end


-- 6.3 吸球转身
function whirlRobotToCarry(role)
	local spdW = function()
		local playerP = player.pos(role)
		local minDis = 9000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(playerP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	

        local b2e =ball.toEnemyDir(minDisEnemy)
	    local b2r = ball.toPlayerDir(role)		
		local subDir = math.abs(b2r-b2e)
		if subDir > skillParam.whirlArcCompare then
			local add = false
			if (b2r * b2e > 0 ) then
				if b2r > 0 then
					if b2r > b2e then
						add = false 
					else
						add = true 
					end 
				else
					if b2r >b2e then
						add = false 
					else
						add = true
					end
				end 
			else
				if b2r > 0 then
					if b2r > b2e + math.pi then
						add = true 
					else
						add = false
					end 
				else
					if b2r >b2e - math.pi then
						add = true
					else
						add = false
					end
				end 
			end 
			if add then
           		if IS_SIMULATION then
					return skillParam.whirlSimulationSpeed
		   		else
					return skillParam.whirlSpeed
		   		end 
			else			
           		if IS_SIMULATION then
					return skillParam.whirlSimulationSpeed1
		   		else
					return skillParam.whirlSpeed1
		   		end 
			end
		else
			return 0
		end	
	
	end
	local idir =function()
		return player.dir(role)
	end
	local ikick = function()
		return 0
	end
    function specifiedFlat()
	   return 0 
	end
    function specifiedChip()
		return 0
	end
	local mexe, mpos = OpenSpeed{speedW = spdW}
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end



-- 7. 协防
-- 防守位置：阻挡接球线
-- n为满足条件的第几个对方机器人
-- 如没有满足条件的对方机器人,返回的当前机器人的位置
-- 对方机器人越靠近本方禁区,优先级越高
function robotDef(role,n)
	local ipos =function()
		local temp
		local sortEnemy = {} 
			local count = 0
	    	for j = 0, param.maxPlayer-1 do
	            if enemy.valid(j) and enemy.pos(j):dist(ball.pos()) > skillParam.exceptDist1 
	            	and enemy.pos(j):dist(CGeoPoint:new_local(param.pitchLength/2,0)) > 1200  then	            	
	            	count = count + 1
	            	sortEnemy[count] = j
	            end            
	    	end
			if n > count then
				return player.pos(role)
			else 
				return enemy.pos(sortEnemy[n]) + Utils.Polar2Vector(skillParam.helpDefDist,(ball.pos() - enemy.pos(sortEnemy[n])):dir())       
			end 	    	
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end




-- 8. 其它
function stop()
	local mexe, mpos = Stop{}
	return {mexe, mpos}
end

function continue()
	return {["name"] = "continue"}
end

function goCmuRush(p, d, a, f, r, v)
	local idir
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

function goSpeciPos(p, d, f, a) -- 2014-03-26 增加a(加速度参数)
	local idir
	local iflag
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end

	if f ~= nil then
		iflag = f
	else
		iflag = 0
	end

	local mexe, mpos = SmartGoto{pos = p, dir = idir, flag = iflag, acc = a}
	return {mexe, mpos}
end








